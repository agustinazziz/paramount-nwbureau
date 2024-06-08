import { api, LightningElement, track, wire } from 'lwc';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Toast from 'lightning/toast';
import { getFieldValue, cartSummaryLabels, getErrorInfo, orderChargeLabels, minOrderLabel, localDateFormat, productListLabels } from 'c/conaB2BUtil';
import getItemsDetails from '@salesforce/apex/Cona_B2BOrderSimulateCtrl.fetchOrderSimulateResponse';
import isOrderBlock from '@salesforce/apex/CONA_B2B_OrderBlockController.isOrderBlock';
import getCartItems from '@salesforce/apex/ConaB2B_CommerceCartItemsCntrl.getCurrentCartItems';
import updateCartData from '@salesforce/apex/CONA_B2BCartUpdate.updateCartData';
import checkAccountVisitPlan from '@salesforce/apex/CONA_B2BDisplayDatesController.checkAccountWithVisitPlan';
import { refreshCartSummary, CartSummaryAdapter } from 'commerce/cartApi';
import { NavigationContext } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import icons from '@salesforce/resourceUrl/conaB2BImages';
import { getRecord } from 'lightning/uiRecordApi';
import WEB_STORE_ID from '@salesforce/webstore/Id';
import analyticsUtil from 'c/conaB2BAnalyticsUtil';
import moment_js from '@salesforce/resourceUrl/moment';
import { loadScript } from 'lightning/platformResourceLoader';
import {MOCK_ITEMS_WITH_MOQ, MOCK_ITEMS, MOCK_ITEMS_WITH_MOV} from './mock504.js';


const REPRICED_EVENT_NAME = 'repricing';
const CHECKOUT_EVENT_NAME = 'proceedtocheckout'
const PRICES_UPDATED_EVENT_NAME = 'pricesupdated'
const ORDER_CHARGE_EVENT_NAME = 'orderchargeapplied';
const MISSING_RECORD = 'MISSING_RECORD';
const MOV_CONDITION_TYPE = 'ZMOV';
const MOQ_CONDITION_TYPE = 'ZMOQ';
const SET_AMOUNT_IN_IFRAME = 'setamountoniframe';
const ORDER_ORIGIN_ECOM = 'E360';
const SALES_DOC_ZOR = 'ZOR';
const WEBSTORE_FIELDS = ['WebStore.Id', 'WebStore.BottlerId__c'];
const WEBCART_FIELDS = ['WebCart.TotalSavings__c', 'WebCart.MOQFee__c', 'WebCart.MOVFee__c', 'Webcart.DeliveryFee__c'];
/**
 * A summary display of cart total costs and savings.
 *
 * Note:
 * "Cart Summary" refers to the entire component. This is the terminology we use internally and to customers.
 * "Totals" refers to the prices that are displayed in the Cart Summary component.
 *
 * @slot headerText ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Summary", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot depositLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Promotions", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot shippingLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Shipping", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot subtotalLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Subtotal", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot taxIncludedLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Tax included", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}", textAlign: "right" }}] })
 * @slot taxLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Tax", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot totalLabel ({ locked: true, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Total", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"heading-small\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot checkout
 * @slot summaryMessage
 */
export default class ConaB2bCommerceCartSummary extends NavigationMixin(LightningElement) {
    /**
     * Enable the component to render as light DOM
     * @static
     */
    static renderMode = 'light';

    @track _cartSummary = {};

    itemFieldMapping = new Map([
        ['itemNumber', 'productDetails.sku'],
        ['material', 'productDetails.fields.ProductCode'],
        ['requestedQuantity', 'quantity'],
        ['requestedQuantityUom', 'productDetails.fields.QuantityUnitOfMeasure']
    ]);

    @api isCheckoutPage;
    isOrderBlock = false;

    promoDiscountIcon = icons + '/conaB2BImages/promoicon.png';
    orderChargeLabels = orderChargeLabels;
    minOrderChargeLabelCona = minOrderLabel;
    labels = cartSummaryLabels;
    /**
     * Gets the AccountId value for Current user
    */
    effectiveAccountId = effectiveAccount.accountId;
    bottlerId;
    cartId;
    cartIdForWire;
    analytics = analyticsUtil;
    defaultDeliveryDate = null;
    isLoading = false;
    webstoreId = WEB_STORE_ID;
    currency;
    @api recordId;
    @wire(NavigationContext)
    navContext;
    /**
     * Gets the current cart content
     */
    @api items;
    
    hasInvalidItems = false;

    get _hasCartItems() {
        return this.items === undefined ? false : this.items.length !== 0;
    }
   
    get orderChargeValue() {
        return this._hasCartItems ? this.orderCharge : 0.0;
    }

    /**
     * Gets or sets the background color, specified as a valid CSS color representation.
     */
    @api backgroundColor;

     /**
     * Gets or sets the mock cart totals for experience builder.
     */
     @track cartTotals;

    /**
     * Gets or sets the color of the discount amount, specified as a valid CSS color representation.
     */
    @api discountAmountTextColor;

    /**
     * Gets or sets the size of the discount amount, currently: 'small', 'medium', 'large'.
     */
    @api discountAmountTextSize;

    /**
     * Gets or sets the color of the original price label text, specified as a valid CSS color representation.
     */
    @api originalTextColor;

    /**
     * Gets or sets the size of the original price label text, currently: 'small', 'medium', 'large'.
     */
    @api originalTextSize;

    /**
     * Gets or sets the color of the shipping price label text, specified as a valid CSS color representation.
     */
    @api shippingTextColor;

    /**
     * Gets or sets the size of the shipping price label text, currently: 'small', 'medium', 'large'.
     */
    @api shippingTextSize;

    /**
     * Whether or not to display the discount price.
     */
    @api showDiscountAmount = false;

    /**
     * Whether or not to show the original price.
     */
    @api showOriginalPrice = false;

    /**
     * Whether or not to show shipping price.
     */
    @api showShippingPrice = false;

    /**
     * Whether or not show subtotal price.
     */
    @api showSubtotalPrice = false;

    /**
     * Whether or not to show the tax included label.
     */
    @api showTaxIncludedLabel = false;

    /**
     * Whether or not to show tax price.
     */
    @api showTaxPrice = false;

    /**
     * Gets or sets the color of the subtotal price label text, specified as a valid CSS color representation.
     */
    @api subtotalTextColor;

    /**
     * Gets or sets the size of the subtotal price label text, currently: 'small', 'medium', 'large'.
     */
    @api subtotalTextSize;

    /**
     * Gets or sets the tax included label text color, specified as a valid CSS color representation.
     */
    @api taxIncludedLabelFontColor;

    /**
     * Gets or sets the tax included label text size, a value of 'small', 'medium', or 'large'.
     */
    @api taxIncludedLabelFontSize;

    /**
     * Gets or sets the color of the tax price label text, specified as a valid CSS color representation.
     */
    @api taxTextColor;

    /**
     * Gets or sets the tax price label text, a value of 'small', 'medium', or 'large'.
     */
    @api taxTextSize;

    /**
     * Gets or sets the total price label text, specified as a valid CSS color representation.
     */
    @api totalTextColor;

    /**
     * Gets or sets the total price label text, a value of 'small', 'medium', or 'large'.
     */
    @api totalTextSize;
    
    /**
     * The totals to be displayed in the cart summary.
    */
   get cartSummaryTotals() {
       return this._hasCartItems ? this.cartTotals || this.defaultCartTotals() : this.defaultCartTotals();
    }

    get cartSummary() {
        return this._hasCartItems ? this._cartSummary : {};
    }
    
    /**
     * The ISO 4217 currency code.
     */
    get currencyCode() {
        return this.currencyIsoCode || this.currency;
    }
    
    summaryInfoLoaded = false;
    moqApplied = false;
    movApplied = false;
    orderCharge = 0;
    showOrderChargeLineItem = false;
    orderChargeLabel;
    firstRenderization = true;
    @api accountVisitPlan = false;

    @api currencyIsoCode;
    
    IsRepricingNeeded = true;
    
    @api showUpdateToCart;
    @api showProceedToCheckout;

    @api
    async updateCartPrices(){
        this.isLoading = true;
        await this.getAllCartItems();
        if (!this.canNotProceedToCheckout) {
            const finishUpdateEvent = new CustomEvent(PRICES_UPDATED_EVENT_NAME, {bubbles: true});
            this.dispatchEvent(finishUpdateEvent); 
        }
    }


    @api
    proceedToCheckoutNavigate(){
        try {
            this.analytics.checkout(this.cartTotals, this.items, this.currency);
        } catch (error) {
            console.log(`:/ Analytics error - `, error);
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/checkout'
            }
        }); 
    }

    get enableUpdateCartButton() {
        return this._hasCartItems && this.accountVisitPlan;
    }

    get canNotProceedToCheckout() {
        return this.IsRepricingNeeded || this.isOrderBlock || !this._hasCartItems;
    }

    get disableButtonCheckout() {
        return !this._hasCartItems || !this.accountVisitPlan;
    }


    /**
     * Whether or not to display the cart summary component.
     */
    get displayCartSummary() {
        return this.cartSummaryTotals !== undefined;
    }

    /**
     * Gets whether or not to show the tax price
     *
     * Tax price will only be displayed when
     *  - the tax type is 'Net'
     *  - and the showTaxPrice builder setting is true
     */
    get _showTaxPrice() {
        return this.showTaxPrice;
    }

    /**
     * Get tax included label.
     *
     * The tax included label will only be displayed if
     *     - mock cartTotals is not provided AND tax type is 'Gross' AND the showTaxIncludedLabel builder setting is true
     *     OR
     *     - mock cartTotals is provided AND the showTaxIncludedLabel builder setting is true
     */
    get _showTaxIncludedLabel() {
        return (!this.cartTotals || !!this.cartTotals) && this.showTaxIncludedLabel;
    }

    get cartSummaryLocalizedErrorMessages() {
        return {
            webstoreNotFound: this.labels.webstoreNotFound,
            effectiveAccountNotFound: this.labels.effectiveAccountNotFound,
            insufficientAccess: this.labels.insufficientAccess,
            defaultErrorMessage: this.labels.defaultErrorMessage,
            invalidInput: this.labels.invalidInput,
            unqualifiedCart: '',
            maximumLimitExceeded: '',
            alreadyApplied: '',
            blockedExclusive: '',
            limitExceeded: '',
            gateDisabled: '',
            tooManyRecords: '',
            itemNotFound: '',
            missingRecord: '',
            invalidBatchSize: ''
        };
    }

    get showPromoDiscountSection() {
        return this.cartSummaryTotals.promoDiscount > 0;
    }

    @wire(checkAccountVisitPlan, {
        accountId: '$effectiveAccountId'
    }) wireAccountVisitPlan({ data, error }) {
        this.accountVisitPlan = data;
        console.log(effectiveAccount);
        if(data === false) {
            const toast = {
                label: productListLabels.conaAccountVisitPlanError,
                variant: 'error'
            };
            Toast.show(toast, this);
        } else if( error ) {
            this.error = error;
        }
    }

    @wire(getRecord, { recordId: '$cartIdForWire', fields: WEBCART_FIELDS })
    wiredCart({ data, error }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (this.isCheckoutPage) {
                return;
            }
            /* this.orderCharge = this.roundUp(
                data.fields?.MOQFee__c?.value ? data.fields?.MOQFee__c?.value : data.fields?.MOVFee__c?.value ? data.fields?.MOVFee__c?.value : 0.0,
                2
            );
            this.cartTotals.promoDiscount = this.roundUp(data.fields?.TotalSavings__c?.value ? data.fields?.TotalSavings__c.value : 0.0, 2);
            this.cartTotals.shippingPrice = this.roundUp(data.fields?.DeliveryFee__c?.value ? data.fields?.DeliveryFee__c.value : 0.0, 2);
            this.cartTotals.total = this.cartTotals.total + this.orderChargeValue + this.cartTotals.shippingPrice - this.cartTotals.promoDiscount;
            if (this.orderChargeValue > 0) {
                this.movApplied = data.fields?.MOVFee__c?.value ? true : false;
                let selectedEvent = new CustomEvent(ORDER_CHARGE_EVENT_NAME, { bubbles: true, detail: { chargeType: this.movApplied ? 'MOV' : 'MOQ' } });
                this.showOrderChargeLineItem = true;
                this.dispatchEvent(selectedEvent);
            } */
        }
    }

    @wire(getRecord, { recordId: '$webstoreId', fields: WEBSTORE_FIELDS })
    wiredWebstore({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.bottlerId = data.fields.BottlerId__c.value;
        }
    }

    /*
     * Retrieves the information for the current cart
     */
    @wire(CartSummaryAdapter)
    async wiredCartSummary({ data, error }) {
    if (data) {
        this._cartSummary = data;
    }

    if (this.summaryInfoLoaded) {
        return;
    }
    if (data) {
        this.cartTotals = {
            shippingPrice: 0.0,
            subtotal: data?.totalProductAmount,
            tax: data?.totalTaxAmount,
            total: parseFloat(data?.grandTotalAmount),
            depositAmount: 0.0,
            promoDiscount: 0.0,
            totalDiscounts: 0.0,
            totalPriceActual: 0.0
        };
        this.currency = data.currencyIsoCode;
        this.cartId = data.cartId;
        this.summaryInfoLoaded = true;
        if (!this.isCheckoutPage) {
            this.cartIdForWire = data.cartId;
        }
    } else if (error) {
        const errorCode = error?.code;
        const errorMessage = error?.message;
        // If the error code is MISSING_RECORD, the cart is empty and we do not surface a toast message
        if (errorCode?.includes(MISSING_RECORD) && errorMessage?.includes(MISSING_RECORD)) {
            const { message } = getErrorInfo(errorCode, this.cartSummaryLocalizedErrorMessages);
            this.showErrorNotification(message);
        }
    }
}

    async connectedCallback() {
        await loadScript(this, moment_js + '/moment.js')
            .then(() => {
                if (sessionStorage.getItem('NextDeliveryDate') && sessionStorage.getItem('NextDeliveryDate') !== 'undefined') {
                    this.defaultDeliveryDate = moment(sessionStorage.getItem('NextDeliveryDate'), localDateFormat)?.clone().format('YYYY-MM-DD');
                }
            })
            .catch((error) => {
                this.isLoading = false;
                this.error = error;
            });
        if (!this.isCheckoutPage && this.firstRenderization) {
            this.firstRenderization = false;
            await this.handleClick();
            this.summaryInfoLoaded = false;
        }
        if (this.isCheckoutPage) {
            await refreshCartSummary();
        }
        await isOrderBlock({ accId: effectiveAccount.accountId })
            .then((result) => {
                if (result.hasOwnProperty('isOrderBlocked')) this.isOrderBlock = result.isOrderBlocked === 'true' ? true : false;
            })
            .catch((err) => {
                this.error = err;
            });
            if (this.isCheckoutPage) {
                await this.handleClick(); 
            } 
          
    }

    async renderedCallback() {
        
    }

    async handleCheckoutButtonClick() {
        this.isLoading = true;
        await this.getAllCartItems();
        if (!this.canNotProceedToCheckout) {
            const proceedToCheckoutEvent = new CustomEvent(CHECKOUT_EVENT_NAME, {bubbles: true});
            this.dispatchEvent(proceedToCheckoutEvent); 
        }
    }
    defaultCartTotals() {
        return {
            subtotal: 0.0,
            shippingPrice: 0.0,
            depositAmount: 0.0,
            tax: 0.0,
            total: 0.0,
            promoDiscount: 0.0,
            totalDiscounts: 0.0,
            totalPriceActual: 0.0
        };
    }
    
    @api resetRepricing() {
        this.IsRepricingNeeded = true;
    }

    async handleClick() {
        this.isLoading = true;
        await this.getAllCartItems();
    }

    async fetchPricingData(requestItems) {
        let requestWrapper = { items: requestItems, isCart: !this.isCheckoutPage };

        await getItemsDetails({
            accountId: this.effectiveAccountId,
            itemWrapper: requestWrapper,
            stringDeliveryDate: this.defaultDeliveryDate
        })
            .then(async (result) => {
                let resultObj = MOCK_ITEMS_WITH_MOV;
                /* let resultObj = JSON.parse(result);  */
                if (resultObj.orderSimulate.return.type === 'E') {
                    let errorMsg = resultObj.orderSimulate.return.text;
                    if (errorMsg.includes(',')) {
                        errorMsg = errorMsg.substring(0, errorMsg.indexOf(','));
                    }
                    this.isLoading = false;
                    this.showErrorNotification(errorMsg);
                    return;
                }
               await this.setPricingDataOnCart(resultObj);
            })
            .catch((error) => {
                this.isLoading = false;
                this.showErrorNotification(error.body.message);
            });
    }

    async setPricingDataOnCart(resultObj) {
        let discountAmountTotal = this.roundUp(resultObj.orderSimulate.header?.totalDiscounts, 2);
        let summaryInformation = {
            subtotal: this.roundUp(resultObj.orderSimulate.header?.subTotal, 2) + discountAmountTotal,
            shippingPrice: this.roundUp(resultObj.orderSimulate.header?.totalFees, 2),
            depositAmount: this.roundUp(resultObj.orderSimulate.header?.totalDeposits, 2),
            tax: this.roundUp(resultObj.orderSimulate.header?.totalTaxes, 2),
            totalDiscounts: discountAmountTotal,
            totalPriceActual: this.roundUp(resultObj.orderSimulate.header?.totalPrice, 2),
            promoDiscount: this.roundUp(Math.abs(discountAmountTotal), 2),
            total:
                this.roundUp(resultObj.orderSimulate.header?.subTotal, 2) +
                this.roundUp(resultObj.orderSimulate.header?.totalDeposits, 2) +
                this.roundUp(resultObj.orderSimulate.header?.totalTaxes, 2) +
                discountAmountTotal +
                this.roundUp(resultObj.orderSimulate.header?.totalFees, 2)
        };
        this.cartTotals = summaryInformation;
        if (!this.isCheckoutPage) {
            const selectedEvent = new CustomEvent(REPRICED_EVENT_NAME, { bubbles: true, detail: resultObj.orderSimulate });
            this.dispatchEvent(selectedEvent);
        }
        await this.checkMovMoq(resultObj);
    }

    async checkMovMoq(data) {
        let orderChargeSum = 0;
        if (data.orderSimulate.moq !== undefined && Array.isArray(data.orderSimulate.moq) && data.orderSimulate.moq.length > 0) {
            data.orderSimulate.moq.forEach((element) => {
                orderChargeSum += parseFloat(element?.fee);
            });
            this.moqApplied = true;
            this.movApplied = false;
        } else {
            data.orderSimulate.condition.forEach((element) => {
                if (element.type === MOV_CONDITION_TYPE && element.isInactive === '') {
                    orderChargeSum += parseFloat(element?.value);
                }
            });
            this.movApplied = true;
            this.moqApplied = false;
        }
        if (!this.movApplied && !this.moqApplied) {
            data.orderSimulate.condition.forEach((element) => {
                if (element.type === MOQ_CONDITION_TYPE && element.isInactive === '') {
                    orderChargeSum += parseFloat(element?.value);
                }
            });
            this.movApplied = false;
            this.moqApplied = true;
        }
        this.orderCharge = this.roundUp(orderChargeSum, 2);
        let selectedEvent;
        if (this.orderCharge > 0) {
            this.cartTotals = {
                ...this.cartTotals,
                total: this.cartTotals.total,
                shippingPrice:
                    this.cartTotals?.shippingPrice !== undefined && this.cartTotals?.shippingPrice !== '' && this.cartTotals?.shippingPrice !== 0
                        ? this.cartTotals?.shippingPrice - this.orderCharge
                        : 0
            };
            selectedEvent = new CustomEvent(ORDER_CHARGE_EVENT_NAME, { bubbles: true, detail: { chargeType: this.movApplied ? 'MOV' : 'MOQ' } });
            this.showOrderChargeLineItem = true;
        } else {
            selectedEvent = new CustomEvent(ORDER_CHARGE_EVENT_NAME, { bubbles: true, detail: { chargeType: 'NA' } });
            this.showOrderChargeLineItem = false;
        }
        if (!this.isCheckoutPage) {
            this.dispatchEvent(selectedEvent);
        }
        await this.savePricingInfoOnWebCart();
        this.IsRepricingNeeded = false;
        /* this.isLoading = false; */
        this.setAmountOnIframe();
    }

    async savePricingInfoOnWebCart() {
        let cartWrapper = {
            cartId: this.cartId,
            deliveryFee: this.cartTotals.shippingPrice,
            deposits: this.cartTotals.depositAmount,
            tax: this.cartTotals.tax,
            movApplied: this.movApplied,
            moqApplied: this.moqApplied,
            movFee: this.movApplied ? this.orderCharge : 0,
            moqFee: this.moqApplied ? this.orderCharge : 0,
            caseCount: parseInt(this.cartSummary.totalProductCount),
            orderTotal: this.cartTotals.total,
            orderSubTotal: this.cartTotals.subtotal,
            bottlerID: this.bottlerId,
            salesDocumentType: SALES_DOC_ZOR,
            orderOrigin: ORDER_ORIGIN_ECOM
        };

        await updateCartData({ cartData: cartWrapper }).then(function (fulfilled) {});

        try {
            this.analytics.updateCart(this.cartTotals, this.items, this.currency);
        } catch (error) {
            console.log(`:/ Analytics error - `, error);
        }
        this.isLoading = false;
    }

    createRequestBodyForCurrentCart() {
        let requestItems = [];
        let indexCount = 0;
        for (let index = 0; index < this.items.length; index++) {
            const element = this.items[index];
            if(getFieldValue(this.itemFieldMapping.get('material'), element)) {
                let requestItem = {
                    itemNumber: (indexCount + 1) * 10,
                    material: getFieldValue(this.itemFieldMapping.get('material'), element),
                    requestedQuantity: getFieldValue(this.itemFieldMapping.get('requestedQuantity'), element),
                    requestedQuantityUom: getFieldValue(this.itemFieldMapping.get('requestedQuantityUom'), element)
                };
                requestItems.push(requestItem);
                indexCount ++;
            }   
            
        }
        return requestItems;
    }

    async getAllCartItems() {
        await getCartItems({ webstoreId: this.webstoreId, effectiveAccountId: this.effectiveAccountId })
            .then(async (result) => {
                this.items = result;
                let request = this.createRequestBodyForCurrentCart();
                await this.fetchPricingData(request);
            })
            .catch((error) => {});
    }

    /**
     * Sets the custom background color and custom CSS properties for the cart summary component.
     */
    get cartSummaryCustomCssStyles() {
        const discountAmountDxpTextSize = this.dxpTextSize(this.discountAmountTextSize);
        const originalDxpTextSize = this.dxpTextSize(this.originalTextSize);
        const shippingDxpTextSize = this.dxpTextSize(this.shippingTextSize);
        const subtotalDxpTextSize = this.dxpTextSize(this.subtotalTextSize);
        const textIncludedLabelDxpTextSize = this.dxpTextSize(this.taxIncludedLabelFontSize);
        const taxDxpTextSize = this.dxpTextSize(this.taxTextSize);
        const totalDxpTextSize = this.dxpTextSize(this.totalTextSize);

        const customStylingProperties = {
            'background-color': this.backgroundColor,
            '--com-c-cart-summary-discount-amount-text-color': this.discountAmountTextColor,
            '--com-c-cart-summary-discount-amount-text-size': `var(${discountAmountDxpTextSize})`,
            '--com-c-cart-summary-original-text-color': this.originalTextColor,
            '--com-c-cart-summary-original-text-size': `var(${originalDxpTextSize})`,
            '--com-c-cart-summary-shipping-text-color': this.shippingTextColor,
            '--com-c-cart-summary-shipping-text-size': `var(${shippingDxpTextSize})`,
            '--com-c-cart-summary-subtotal-text-color': this.subtotalTextColor,
            '--com-c-cart-summary-subtotal-text-size': `var(${subtotalDxpTextSize})`,
            '--com-c-cart-summary-tax-included-label-font-color': this.taxIncludedLabelFontColor,
            '--com-c-cart-summary-tax-included-label-font-size': `var(${textIncludedLabelDxpTextSize})`,
            '--com-c-cart-summary-tax-text-color': this.taxTextColor,
            '--com-c-cart-summary-tax-text-size': `var(${taxDxpTextSize})`,
            '--com-c-cart-summary-total-text-color': this.totalTextColor,
            '--com-c-cart-summary-total-text-size': `var(${totalDxpTextSize})`
        };
        let styleArray = [];
        Object.keys(customStylingProperties).forEach(function (k) {
            styleArray.push(k + ':' + customStylingProperties[k]);
        });
        return styleArray.join(';');
    }
    /**
     * Gets the associated dxp CSS font size property for the given text size.
     *
     * @param {string} fontSizeValue
     *  The size of heading to be reflected by the returned CSS class.
     *  Valid values are: "small", "medium", and "large"
     *
     * @returns {string}
     *  The dxp CSS property matching the requested size, if one exists; otherwise, an empty string.
     */
    dxpTextSize(fontSizeValue) {
        switch (fontSizeValue) {
            case 'small':
                return '--dxp-s-text-heading-small-font-size';
            case 'medium':
                return '--dxp-s-text-heading-medium-font-size';
            case 'large':
                return '--dxp-s-text-heading-large-font-size';
            default:
                return '';
        }
    }

    showErrorNotification(message) {
        Toast.show(
            {
                label: message,
                variant: 'error',
                mode: 'dismissible'
            },
            this
        );
    }

    @api
    repriceItems(detail) {
        this.setPricingDataOnCart(detail);
    }
    @api
    setInvalidItemFlag(detail) {
        this.hasInvalidItems = detail.invalidItemPresent === true ? true : false;
    }

    setAmountOnIframe(event) {
        const selectedEvent = new CustomEvent(SET_AMOUNT_IN_IFRAME, { bubbles: true, detail: this.cartSummaryTotals });
        this.dispatchEvent(selectedEvent);
    }

    round(value, precision) {
        return parseFloat(parseFloat(value).toFixed(precision));
    }
    roundUp(value, precision) {
        return this.round(this.round(value, precision + 1), precision);
    }
}