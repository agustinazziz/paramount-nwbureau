import { LightningElement, wire, api } from 'lwc';
import hasBuyerAccessForCurrentEffectiveAccount from '@salesforce/apex/CONA_B2BUtils.hasBuyerAccessForCurrentEffectiveAccount';
import hasOrderUserPermission from '@salesforce/customPermission/CONA_B2B_Order';
import BuilderContextHandler from 'c/conaB2BBuilderContextHandler';
import { NavigationMixin } from 'lightning/navigation';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
/**
 * @slot cart
 * @slot cartSummary
 * @slot marketingContent
 */
export default class ConaB2BCartPageContainer extends NavigationMixin(BuilderContextHandler(LightningElement)) {
     @api effectiveAccountIdMock;
     @api currentCartIdMock;
    /**
     * Enable the component to render as light DOM
     * @static
     */
    static renderMode = 'light';

    hasBuyerAccess = false;

    effectiveAccount = effectiveAccount.accountId;

    isLoading = true;

    get isOrderUser(){
        return hasOrderUserPermission;
    }

    get hasCartAccess() {
        return (this.isOrderUser && this.hasBuyerAccess) || this.isBuilderContext;
    }

    @wire(hasBuyerAccessForCurrentEffectiveAccount, {effectiveAccountId: '$effectiveAccount'})
    hasBuyerAccessForCurrentEffectiveAccountWired({data, error}) {
        if(this.isValueTypeOfBoolean(data)) {
            this.hasBuyerAccess = data;
            this.navigateToHomePageWhenNoCartAccess();
            this.isLoading = false;
        } else if(error) {
            this.isLoading = false;
            this.hasBuyerAccess = false;
            this.navigateToHomePageWhenNoCartAccess();
        }
    }


    handleCartItemUpdate() {
        let ele = this.querySelector('c-cona-b2b-commerce-cart-summary');
        if (ele) {
            ele.resetRepricing();
        }
    }
    handleRepricing(event) {
        let ele = this.querySelector('c-cona-b2-b-commerce-cart-items');
        if (ele) {
            ele.repriceItems(event.detail);
        }
    }
    handlePricesUpdated() {
        let ele = this.querySelector('c-cona-b2-b-commerce-cart-items');
        if (ele) {
            ele.validateDeleteInvalidItems();
        }
    }
    handleCheckAlertsAndUpdateCart() {
        let ele = this.querySelector('c-cona-b2-b-commerce-cart-items');
        if(ele) {
            ele.refreshItemsOnCart();
        }
    }
    handleUpdateCartPrices() {
        let ele = this.querySelector('c-cona-b2b-commerce-cart-summary');
        if (ele) {
            ele.updateCartPrices();
        }
    }
    handleNavigateToCheckout() {
        let ele = this.querySelector('c-cona-b2b-commerce-cart-summary');
        if(ele) {
            ele.proceedToCheckoutNavigate();
        }
    }
    hangleOrderChargeApplied(event) {
        let ele = this.querySelector('c-cona-b2-b-commerce-cart-items');
        if (ele) {
            ele.processOrderChargeEvent(event.detail);
        }
    }
    handleDisableUpdateCart(event) {
        let ele = this.querySelector('c-cona-b2b-commerce-cart-summary');
        if (ele) {
            ele.setInvalidItemFlag(event.detail);
        }
    }

    navigateToHomePageWhenNoCartAccess() {
        if(this.hasBuyerAccessBeenInit() && !this.hasCartAccess) {
            this.navigateToHomePage();
        }
    }

    hasBuyerAccessBeenInit() {
        return this.isValueTypeOfBoolean(this.hasBuyerAccess);
    }

    isValueTypeOfBoolean(value) {
        return typeof value === 'boolean';
    }

    navigateToHomePage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }

}