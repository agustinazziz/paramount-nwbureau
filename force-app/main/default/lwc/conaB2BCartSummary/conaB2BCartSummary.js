import { LightningElement, api,track } from 'lwc';

/**
 * A summary display of cart total prices.
 */
export default class ConaB2BCartSummary extends LightningElement {
    /**
     * Enable the component to render as light DOM
     *
     * @static
     */
    static renderMode = 'light';

    /**
     * The pricing information to be displayed for the cart totals.
     * Accepts an object of the form
     *
     * {
     *     originalPrice: string | undefined;
     *     shippingPrice: string | undefined;
     *     subtotal: string | undefined;
     *     deposit: string | undefined;
     *     tax: string | undefined;
     *     total: string | undefined;
     * }
     *
     * If a value is not provided for a property, the corresponding price label will not be displayed.
     */

    get showTaxAndDeposit() {
        return this.isCheckout || this.isOrderDetail;
    }
    @api cartTotals;

    @api orderChargeValue;

    @api showOrderCharge;
    /**
     * The ISO 4217 currency code
     */
    @api currencyCode;

    @api isCheckout;

    @api isOrderDetail;

    @track summaryClass = 'summaryCardClosed';
    showContent = true;

    toggleContentShow() {
        this.showContent = true;
        this.summaryClass = 'summaryCardOpen';
    }

    toggleContentHide() {
        this.showContent = false;
        this.summaryClass = 'summaryCardClosed';
    }
}