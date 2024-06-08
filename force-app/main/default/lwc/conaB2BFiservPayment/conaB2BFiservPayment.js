import { LightningElement, wire, api } from 'lwc';
import Toast from 'lightning/toast';
import getIframeRequestID from '@salesforce/apex/CONA_B2BFiservPaymentController.getIframeRequestID';
import getPaymentMethod from '@salesforce/apex/CONA_B2BFiservPaymentController.getPaymentMethod';
import saveDataInPlatformCache from '@salesforce/apex/CONA_B2BCartUpdate.saveDetailsForCartInSession';
import requestTokenApiEndpoint from '@salesforce/label/c.CONA_B2BSnapPayRequestTokenAPILabel';
import isOrderBlock from '@salesforce/apex/CONA_B2B_OrderBlockController.isOrderBlock';
import checkAccountVisitPlan from '@salesforce/apex/CONA_B2BDisplayDatesController.checkAccountWithVisitPlan';
import { paymentSectionCheckout } from 'c/conaB2BUtil';
import { CartItemsAdapter } from 'commerce/cartApi';
import images from '@salesforce/resourceUrl/conaB2BImages';
import infoIcon from '@salesforce/resourceUrl/infoIcon';
import basePath from '@salesforce/community/basePath';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import webstoreId from '@salesforce/webstore/Id';
import { NavigationMixin } from 'lightning/navigation';

import { getRecord } from 'lightning/uiRecordApi';
import PAY_OPTIONS from '@salesforce/schema/Account.Payment_Options__c';
import PO_REQUIRED from '@salesforce/schema/Account.PORequiredFlag__c';
import PAYMENT_TERMS from '@salesforce/schema/Account.PaymentTerms__r.Key__c';

import hasOrderUserPermission from '@salesforce/customPermission/CONA_B2B_Order';
import hasPayerUserPermission from '@salesforce/customPermission/CONA_B2BFinancialUser';

const FIELDS_ACCOUNT = [PAY_OPTIONS, PAYMENT_TERMS, PO_REQUIRED];
// Set the transactionType to "Authorization" for Credit Card and "Sale" for ACH
const transactionType = { Authorization: 'A', Tokenize: 'T', Sale: 'S' };
const paymentMethod = { CreditCard: 'CC', ACH: 'ACH' };
const NET_DUE = 'netDueOnDelivery';
const INVOICE_ME = 'invoiceMe';
const AUTOPAY = 'autopay';
const SHORT_YES = 'Y';
const SHORT_NO = 'N';
const PAYMENT_METHOD_BOX_DISABLED_CLASS = 'paymentMethodBox--disabled';
const PAYMENT_METHOD_ACTION_IDS = ['credCard', 'eCheck', 'invoiceMe', 'netDueOnDelivery', 'autopay'];

export default class conaB2BFiservPayment extends NavigationMixin(LightningElement) {
    /**
     * Enable the component to render as light DOM
     *
     * @static
     */
    static renderMode = 'light';
    loadingIframe = false;
    companycode;
    customerid;
    effectiveAccountId = effectiveAccount.accountId;
    isReloaded = false;
    theIframe;
    totalCartPrice;
    paymentIcon = images + '/conaB2BImages/paymentInfoIcon.png';
    termsAndCondIcon = infoIcon;
    selected;
    showPlaceOrder = false;
    showIframe = false;
    redirectUrl = `https://${location.host}` + basePath + '/paymentauthorization';
    poNumber;
    snapPayRequestId;
    isOrderBlock = false;
    placeOrderView;
    cartId;
    @api totalCartAmount;

    @api deliveryData;
    @api shippingMethod;

    paymentTerms;
    paymentOptions;
    showInvoice = false;
    showCC = false;
    showECheck = false;
    showNetDue = false;
    showAutopay = false;

    serverError = false;

    paymentMethodType;
    poRequired;

    get requiredPoNumber() {
        return this.poRequired;
    }

    /** Getters for Labels start */

    get paymentIframeClass() {
        return this.isOrderBlock ? 'iframe-container slds-p-horizontal_x-small blur-section' : 'iframe-container slds-p-horizontal_x-small';
    }

    /**
     * Gets paymentInformation label
     */
    get paymentInformationLabel() {
        return paymentSectionCheckout.paymentInformation;
    }

    /**
     * Gets paymentMethod label
     */
    get paymentMethodLabel() {
        return paymentSectionCheckout.paymentMethod;
    }

    /**
     * Gets cardMethod label
     */
    get cardMethodLabel() {
        return paymentSectionCheckout.cardMethod;
    }

    /**
     * Gets eCheckMethod label
     */
    get eCheckMethodLabel() {
        return paymentSectionCheckout.eCheckMethod;
    }

    /**
     * Gets invoiceMethod label
     */
    get invoiceMethodLabel() {
        return paymentSectionCheckout.invoiceMethod;
    }

    /**
     * Gets netDue label
     */
    get netDueLabel() {
        return paymentSectionCheckout.netDue;
    }

    /**
     * Gets uponDelivery label
     */
    get uponDeliveryLabel() {
        return paymentSectionCheckout.uponDelivery;
    }

    get autopayLabel() {
        return paymentSectionCheckout.autoPayText;
    }

    /**
     * Gets termsAndConditions label
     */
    get termsAndConditionsLabel() {
        return paymentSectionCheckout.termsAndConditions;
    }

    /**
     * Gets requestTokenApiEndpoint label
     */
    get requestTokenApiEndpointLabel() {
        return paymentSectionCheckout.requestTokenApiEndpoint;
    }

    /**
     * Gets inputPoNumber label
     */
    get inputPoNumberLabel() {
        return paymentSectionCheckout.poNumberLabel;
    }

    /**
     * Gets Add Items To Cart label
     */
    get loadingLabel() {
        return paymentSectionCheckout.loading;
    }

    /**
     * Gets Add Items To Cart label
     */
    get privacyPolicyTextLabel() {
        return paymentSectionCheckout.privacyPolicyText;
    }

    /**
     * Gets Add Items To Cart label
     */
    get andTextLabel() {
        return paymentSectionCheckout.andText;
    }

    /**
     * Gets Add Items To Cart label
     */
    get termsCondtionsSubTextLabel() {
        return paymentSectionCheckout.termsCondtionsSubText;
    }

    /** Getters for Labels end */

    get snapPayReqId() {
        return this.snapPayRequestId;
    }

    set snapPayReqId(value) {
        this.snapPayRequestId = value;
        this.getRequestTokenFromSnapPay();
    }

    get sourceUrl() {
        return requestTokenApiEndpoint + this.snapPayReqId;
    }

    get finalCartPrice() {
        return this.totalCartPrice;
    }

    get payOptions() {
        return this.paymentOptions;
    }

    get paymentTermValue() {
        return this.paymentTerms;
    }

    get invoiceShow() {
        return this.showInvoice;
    }

    get ccShow() {
        return this.showCC;
    }

    get eCheckShow() {
        return this.showECheck;
    }

    get netDueShow() {
        return this.showNetDue;
    }

    get autopayShow() {
        return this.showAutopay;
    }

    get iframeError() {
        return this.serverError;
    }

    @api
    get transactionAmount() {
        return this.totalCartAmount;
    }

    get displayAndSave() {
        return hasPayerUserPermission ? SHORT_YES : SHORT_NO;
    }

    get savePaymentMethod() {
        return hasOrderUserPermission || hasPayerUserPermission ? SHORT_YES : SHORT_NO;
    }

    get saveAtCustomer() {
        return hasPayerUserPermission ? SHORT_YES : SHORT_NO;
    }

    requestPayload = {};

    @wire(getRecord, { recordId: '$effectiveAccountId', fields: FIELDS_ACCOUNT })
    wiredPoReqired({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.poRequired = data.fields.PORequiredFlag__c?.value;
        }
    }

    @wire (getPaymentMethod,{recordId: effectiveAccount.accountId})
	paymentMethods({data, error}){
		if(data) {
			for (let i = 0; i < data.length; i++) {
               if(data[i] == 'AP'){
                this.showAutopay = true;
               }
               else if(data[i] == 'CC'){
                this.showCC = true;
               }
               else if(data[i] == 'ACH'){
                this.showECheck = true;
               }
               else if(data[i] == 'UP'){
                this.showNetDue = true;
               }
               else if(data[i] == 'IM'){
                this.showInvoice = true;
               }
            }
		}else {
			this.error = error;
		}
	}

    @wire(CartItemsAdapter)
    wiredCartData({ data, error }) {
        if (data) {
            this.disableNotSelectedPaymentMethods();

            this.error = undefined;
            this.requestPayload.redirecturl = this.redirectUrl;
            this.requestPayload.accountId = data.cartSummary.accountId;
            this.requestPayload.webstoreId = webstoreId;
            this.totalCartPrice = data.cartSummary.totalProductAmountAfterAdjustments;
            this.requestPayload.currencyIsoCode = data.cartSummary.currencyIsoCode;
            this.cartId = data.cartSummary.cartId;
            this.getRequestTokenFromSnapPay();
        } else if (error) {
            this.error = error;
        }
    }

    getRequestTokenFromSnapPay() {
        let deliveryData = { ...this.deliveryData };
        deliveryData.cartId = this.cartId;
        deliveryData.accountId = this.effectiveAccountId;
        deliveryData.poNumber = this.poNumber;
        this.updateDeliveryInformation(deliveryData);
        this.snapPayRequestId = null;
        if (this.selected) {
            if (this.selected.title === 'showCCIframe') {
                this.requestPayload.transactiontype = transactionType.Authorization;
                this.requestPayload.paymentmethod = paymentMethod.CreditCard;
            } else if (this.selected.title === 'showECheckIframe') {
                this.requestPayload.transactiontype = transactionType.Authorization;
                this.requestPayload.paymentmethod = paymentMethod.ACH;
            }
        }
        this.requestPayload.cartPrice = this.transactionAmount;
        this.requestPayload.displayAndSave = this.displayAndSave;
        this.requestPayload.savePaymentMethod = this.savePaymentMethod;
        this.requestPayload.saveAtCustomer = this.saveAtCustomer;
        const spinnerContainer = this.querySelector('.slds-spinner_container');
        if (this.selected) {
            this.resetPlaceOrderVisibility(this.selected, false);
        }
        if (this.requestPayload.paymentmethod && this.requestPayload.accountId) {
            if (this.requestPayload.paymentmethod === paymentMethod.ACH) {
                sessionStorage.setItem('transactionAmount', this.transactionAmount);
            }
            console.log('::: REQUEST PAY LOAD  1 ::: ' + JSON.stringify(this.requestPayload));
            getIframeRequestID({ requestPayload: this.requestPayload })
                .then((result) => {
                    if (spinnerContainer) {
                        spinnerContainer.classList.remove('slds-hide');
                    }
                    this.error = undefined;
                    let response = JSON.parse(result);
                    console.log('::: RESPONSE ::: ' + JSON.stringify(response));
                    if (response.status === SHORT_NO) {
                        console.log('::: RESPONSE MESSAGE ::: ' + response.message);
                        this.showErrorToast(response.message);
                    } else {
                        this.snapPayRequestId = response.requestid;
                        sessionStorage.setItem('requestToken', response.requestid);
                        this.hideSpinnerOnIframe();
                        this.serverError = false;
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.serverError = true;
                })
                .finally(() => {
                    this.hideSpinnerOnIframe();
                });
        } else {
            this.showIframe = false;
        }
    }

    /**
     * show loading spinner while iFrame content loads
     */
    connectedCallback() {
        this.loadingIframe = true;
        isOrderBlock({ accId: effectiveAccount.accountId })
            .then((result) => {
                if (result.hasOwnProperty('isOrderBlocked')) this.isOrderBlock = result.isOrderBlocked === 'true' ? true : false;
            })
            .catch((err) => {
                this.error = err;
            });

        checkAccountVisitPlan({ accountId: effectiveAccount.accountId })
            .then((result) => {
                console.log('checkAccountVisitPlan');
                this.placeOrderView = !result || this.isOrderBlock;

            })
            .catch((err) => {
                this.error = err;
            });
    }

    renderedCallback() {
        this.serverError = false;
        if (!this.selected) {
            if (this.paymentTerms === 'CPP1' && !this.payOptions) {
                this.selected = this.querySelector('[data-id="autopay"]');
            } else {
                this.selected = this.querySelector('.paymentMethodBox');
            }

            this.disableNotSelectedPaymentMethods();

            if (this.selected) {
                this.selected.classList.add('paymentMethodBoxFocus');
                this.resetPlaceOrderVisibility(this.selected);
            }
        }
    }

    disableNotSelectedPaymentMethods() {
        if (this.selected) {
            const clickedActionId =  this.selected?.dataset?.id;
            this.toggleNotClickedActions(true, clickedActionId);
        }
    }

    handlePaymentMethodClick(event) {
        if(this.loadingIframe) {
            return;
        }

        this.loadingIframe = true;
        event.stopPropagation();
        event.target.classList.add('paymentMethodBoxFocus');

        const clickedActionId = event.currentTarget?.dataset?.id;

        this.toggleNotClickedActions(true, clickedActionId);
        this.selected = event.currentTarget;
        this.unselect();
        this.resetPlaceOrderVisibility(event.currentTarget);
    }

    getNotClickedPaymentMethodActionsSelector(clickedActionId) {
        return PAYMENT_METHOD_ACTION_IDS
            .filter((actionId) => actionId !== clickedActionId)
            .map((notClickedActionId) => `[data-id="${notClickedActionId}"]`).join(', ');
    }

    toggleNotClickedActions(disable, clickedActionId) {
        const notClickedActionElems = Array.from(this.querySelectorAll(this.getNotClickedPaymentMethodActionsSelector(clickedActionId)));

        if(notClickedActionElems && notClickedActionElems.length > 0) {
            notClickedActionElems.forEach((notClickedActionElem) => {
                if(disable) {
                    if(!notClickedActionElem.classList.contains(PAYMENT_METHOD_BOX_DISABLED_CLASS)) {
                        notClickedActionElem.classList.add(PAYMENT_METHOD_BOX_DISABLED_CLASS);
                    }
                } else {
                    notClickedActionElem.classList.remove(PAYMENT_METHOD_BOX_DISABLED_CLASS);
                }

            });
        }
    }

    resetPlaceOrderVisibility(selectedOption, getNewRequest = true) {
        if (
            selectedOption.dataset.id.search(NET_DUE) > -1 ||
            selectedOption.dataset.id.search(INVOICE_ME) > -1 ||
            selectedOption.dataset.id.search(AUTOPAY) > -1
        ) {
            this.showPlaceOrder = true;
            this.showIframe = false;
            this.loadingIframe = false;
            this.paymentMethodType = selectedOption.textContent;
            this.toggleNotClickedActions(false);
        } else {
            this.showIframe = true;
            this.showPlaceOrder = false;
            if (getNewRequest) {
                this.getRequestTokenFromSnapPay();
            }
        }
    }

    unselect() {
        this.querySelectorAll('.paymentMethodBox').forEach((element) => {
            if (this.selected.textContent !== element.textContent) {
                element.classList.remove('paymentMethodBoxFocus');
            } else {
                element.classList.add('paymentMethodBoxFocus');
            }
        });
    }

    setPoNumber(event) {
        this.poNumber = event.target.value;
        let deliveryData = { ...this.deliveryData };
        deliveryData.cartId = this.cartId;
        deliveryData.accountId = this.effectiveAccountId;
        deliveryData.poNumber = this.poNumber;
        this.updateDeliveryInformation(deliveryData);
        let searchCmp = this.querySelector('.poNumberField');
        let searchvalue = searchCmp.value;
        if (searchvalue) {
            searchCmp.setCustomValidity('');
        }
        searchCmp.reportValidity();
    }
    handlePoNumber(event) {
        let searchCmp = this.querySelector('.poNumberField');
        let searchvalue = searchCmp.value;

        if (!searchvalue) {
            searchCmp.setCustomValidity(this.inputPoNumberLabel);
        } else {
            searchCmp.setCustomValidity('');
        }
        searchCmp.reportValidity();
    }

    hideSpinnerOnIframe() {
        const spinnerContainer = this.querySelector('.slds-spinner_container');
        const iframe = this.querySelector('iframe');
        if (iframe) {
            iframe.onload = () => {
                this.loadingIframe = false;

                if(spinnerContainer) {
                    spinnerContainer.classList.add('slds-hide');
                }

                this.toggleNotClickedActions(false);
            };
        }
    }

    privacyPolicyLink() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/privacy'
            }
        }).then((generatedUrl) => {
            window.open(generatedUrl, '_blank');
        });
    }

    termsConditionsLink() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/terms-of-use'
            }
        }).then((generatedUrl) => {
            window.open(generatedUrl, '_blank');
        });
    }
    @api
    updateDeliveryInformation(data) {
        let modifiedData = data;
        modifiedData.cartId = this.cartId;
        modifiedData.accountId = this.effectiveAccountId;
        saveDataInPlatformCache({ data: JSON.stringify(modifiedData), accountId: this.effectiveAccountId, cartId: this.cartId });
    }

    showErrorToast(message) {
        const toast = {
            label: message,
            variant: 'error'
        };

        Toast.show(toast, this);
    }
}