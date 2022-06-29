// SPDX-License-Identifier: MIT

import "./abstract/ReaperBaseStrategyv3.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/CErc20I.sol";
import "./interfaces/IComptroller.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/MathUpgradeable.sol";

pragma solidity 0.8.11;

/**
 * @dev This strategy will deposit in to the Tarot lending optimizer vault as a wrapper
 * to allow farming an existing vault+strategy from a new multi-strategy setup
 */
contract ReaperStrategyScreamLeverage is ReaperBaseStrategyv3 {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    /**
     * @dev Initializes the strategy. Sets parameters, saves routes, and gives allowances.
     * @notice see documentation for each variable above its respective declaration.
     */
    function initialize(
        address _vault,
        address[] memory _feeRemitters,
        address[] memory _strategists,
        address[] memory _multisigRoles,
        address _want
    ) public initializer {
        want = _want;
        __ReaperBaseStrategy_init(_vault, want, _feeRemitters, _strategists, _multisigRoles);
    }

    function _adjustPosition(uint256 _debt) internal override {
        // if (emergencyExit) {
        //     return;
        // }

        // uint256 wantBalance = balanceOfWant();
        // if (wantBalance > _debt) {
        //     uint256 toReinvest = wantBalance - _debt;
        //     _deposit(toReinvest);
        // }
    }

    /**
     * @dev Function that puts the funds to work.
     * It supplies {want} to Scream to farm {SCREAM} tokens
     */
    function _deposit(uint256 _amount) internal {
        // IERC20Upgradeable(want).safeIncreaseAllowance(
        //     address(cWant),
        //     _amount
        // );
        // CErc20I(cWant).mint(_amount);
        // uint256 _ltv = _calculateLTV();

        // if (_shouldLeverage(_ltv)) {
        //     _leverMax();
        // } else if (_shouldDeleverage(_ltv)) {
        //     _deleverage(0);
        // }
    }

    function _liquidatePosition(uint256 _amountNeeded)
        internal
        override
        returns (uint256 liquidatedAmount, uint256 loss)
    {
        // uint256 wantBal = IERC20Upgradeable(want).balanceOf(address(this));
        // if (wantBal < _amountNeeded) {
        //     _withdraw(_amountNeeded - wantBal);
        //     liquidatedAmount = IERC20Upgradeable(want).balanceOf(address(this));
        // } else {
        //     liquidatedAmount = _amountNeeded;
        // }
        // loss = _amountNeeded - liquidatedAmount;
    }

    function _liquidateAllPositions() internal override returns (uint256 amountFreed) {
        // _deleverage(type(uint256).max);
        // _withdrawUnderlying(balanceOfPool);
        // return balanceOfWant();
    }

    /**
     * @dev Withdraws funds and sents them back to the vault.
     * It withdraws {want} from Scream
     * The available {want} minus fees is returned to the vault.
     */
    function _withdraw(uint256 _withdrawAmount) internal {
        // uint256 wantBalance = IERC20Upgradeable(want).balanceOf(address(this));
        // if (_withdrawAmount <= wantBalance) {
        //     IERC20Upgradeable(want).safeTransfer(vault, _withdrawAmount);
        //     return;
        // }

        // uint256 _ltv = _calculateLTVAfterWithdraw(_withdrawAmount);

        // if (_shouldLeverage(_ltv)) {
        //     // Strategy is underleveraged so can withdraw underlying directly
        //     _withdrawUnderlying(_withdrawAmount);
        //     _leverMax();
        // } else if (_shouldDeleverage(_ltv)) {
        //     _deleverage(_withdrawAmount);

        //     // Strategy has deleveraged to the point where it can withdraw underlying
        //     _withdrawUnderlying(_withdrawAmount);
        // } else {
        //     // LTV is in the acceptable range so the underlying can be withdrawn directly
        //     _withdrawUnderlying(_withdrawAmount);
        // }
    }

    /**
     * @dev Calculates the total amount of {want} held by the strategy
     * which is the balance of want + the total amount supplied to Scream.
     */
    function balanceOf() public view override returns (uint256) {
        // return balanceOfWant() + balanceOfPool;
    }

    /**
     * @dev Calculates the balance of want held directly by the strategy
     */
    function balanceOfWant() public view returns (uint256) {
        // return IERC20Upgradeable(want).balanceOf(address(this));
    }

    /**
     * @dev Core function of the strat, in charge of collecting and re-investing rewards.
     * @notice Assumes the deposit will take care of the TVL rebalancing.
     * 1. Claims {SCREAM} from the comptroller.
     * 2. Swaps {SCREAM} to {WFTM}.
     * 3. Claims fees for the harvest caller and treasury.
     * 4. Swaps the {WFTM} token for {want}
     * 5. Deposits.
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
        // _claimRewards();
        // _swapRewardsToWftm();
        // callerFee = _chargeFees();
        // _swapToWant();
        
        // uint256 allocated = IVault(vault).strategies(address(this)).allocated;
        // updateBalance();
        // uint256 totalAssets = balanceOf();
        // uint256 toFree = _debt;

        // if (totalAssets > allocated) {
        //     uint256 profit = totalAssets - allocated;
        //     toFree += profit;
        //     roi = int256(profit);
        // } else if (totalAssets < allocated) {
        //     roi = -int256(allocated - totalAssets);
        // }

        // (uint256 amountFreed, uint256 loss) = _liquidatePosition(toFree);
        // repayment = MathUpgradeable.min(_debt, amountFreed);
        // roi -= int256(loss);
    }
}