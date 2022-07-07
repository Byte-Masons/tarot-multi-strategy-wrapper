// SPDX-License-Identifier: MIT

import "./abstract/ReaperBaseStrategyv4.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IVaultv1_4.sol";
import "./interfaces/ILendingOptimizerStrategy.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";
import {FixedPointMathLib} from "./library/FixedPointMathLib.sol";

pragma solidity 0.8.11;

/**
 * @dev This strategy will deposit in to the Tarot lending optimizer vault as a wrapper
 * to allow farming an existing vault+strategy from a new multi-strategy setup
 */
contract ReaperStrategyTarot is ReaperBaseStrategyv4 {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using FixedPointMathLib for uint256;

    // 3rd-party contract addresses
    IVaultv1_4 public tarotCrypt;
    ILendingOptimizerStrategy public tarotStrategy;

    /**
     * @dev Initializes the strategy. Sets parameters, saves routes, and gives allowances.
     * @notice see documentation for each variable above its respective declaration.
     */
    function initialize(
        address _vault,
        address[] memory _feeRemitters,
        address[] memory _strategists,
        address[] memory _multisigRoles,
        address _want,
        address _tarotCrypt,
        address _tarotStrategy
    ) public initializer {
        want = _want;
        tarotCrypt = IVaultv1_4(_tarotCrypt);
        tarotStrategy = ILendingOptimizerStrategy(_tarotStrategy);
        __ReaperBaseStrategy_init(_vault, want, _feeRemitters, _strategists, _multisigRoles);
    }

    function _adjustPosition(uint256 _debt) internal override {
        if (emergencyExit) {
            return;
        }

        uint256 wantBalance = balanceOfWant();
        if (wantBalance > _debt) {
            uint256 toReinvest = wantBalance - _debt;
            _deposit(toReinvest);
        }
    }

    /**
     * @dev Function that puts the funds to work.
     * It supplies {want} to the Tarot lending optimizer crypt to earn interest
     */
    function _deposit(uint256 _amount) internal {
        IERC20Upgradeable(want).safeIncreaseAllowance(
            address(tarotCrypt),
            _amount
        );
        tarotCrypt.deposit(_amount);
    }

    function _liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 liquidatedAmount, uint256 loss)
    {
        uint256 wantBal = balanceOfWant();
        if (wantBal < _amountNeeded) {
            _withdraw(_amountNeeded - wantBal);
            liquidatedAmount = IERC20Upgradeable(want).balanceOf(address(this));
        } else {
            liquidatedAmount = _amountNeeded;
        }
        loss = _amountNeeded - liquidatedAmount;
    }

    function _liquidateAllPositions() internal override returns (uint256 amountFreed) {
        _withdraw(balanceOfPool());
        return balanceOfWant();
    }

    /**
     * @dev Withdraws funds and sents them back to the vault.
     * It withdraws {want} from the Tarot lending optimizer crypt
     * The available {want} minus fees is returned to the vault.
     */
    function _withdraw(uint256 _withdrawAmount) internal {
        tarotStrategy.updateExchangeRates();
        uint256 poolBalance = balanceOfPool();
        if (poolBalance < _withdrawAmount) {
            _withdrawAmount = poolBalance;
        }
        uint256 sharesToWithdraw = _withdrawAmount * 1e18 / tarotCrypt.getPricePerFullShare();
        uint256 shareBalance = tarotCrypt.balanceOf(address(this));

        if (shareBalance < sharesToWithdraw) {
            sharesToWithdraw = shareBalance;
        }

        if (sharesToWithdraw == 0) {
            uint256 sharesToWithdrawCeil = _withdrawAmount.mulDivUp(1e18, tarotCrypt.getPricePerFullShare());
            sharesToWithdraw = MathUpgradeable.min(shareBalance, sharesToWithdrawCeil);
        }

        if (sharesToWithdraw != 0) {
            tarotCrypt.withdraw(sharesToWithdraw);
        }
    }

    /**
     * @dev Calculates the total amount of {want} held by the strategy
     * which is the balance of want + the total amount supplied to the tarot crypt.
     */
    function balanceOf() public view override returns (uint256) {
        return balanceOfWant() + balanceOfPool();
    }

    /**
     * @dev Calculates the balance of want held directly by the strategy
     */
    function balanceOfWant() public view returns (uint256) {
        return IERC20Upgradeable(want).balanceOf(address(this));
    }

    /**
     * @dev Calculates the balance of want held in the Tarot crypt
     */
    function balanceOfPool() public view returns (uint256) {
        uint256 tarotCryptShares = tarotCrypt.balanceOf(address(this));
        uint256 pricePerShare = tarotCrypt.getPricePerFullShare();
        uint256 poolBalance = pricePerShare * tarotCryptShares / 1e18;
        return poolBalance;
    }

    /**
     * @dev Core function of the strat, updates tarot exchange rates to accrue fees and handles debt.
     */
    function _harvestCore(uint256 _debt)
        internal
        override
        returns (
            uint256 callerFee,
            int256 roi,
            uint256 repayment
        )
    {
        uint256 allocated = IVault(vault).strategies(address(this)).allocated;
        tarotStrategy.updateExchangeRates();
        uint256 totalAssets = balanceOf();
        uint256 toFree = _debt;

        if (totalAssets > allocated) {
            uint256 profit = totalAssets - allocated;
            toFree += profit;
            roi = int256(profit);
        } else if (totalAssets < allocated) {
            roi = -int256(allocated - totalAssets);
        }

        (uint256 amountFreed, uint256 loss) = _liquidatePosition(toFree);
        repayment = MathUpgradeable.min(_debt, amountFreed);
        roi -= int256(loss);
    }
}