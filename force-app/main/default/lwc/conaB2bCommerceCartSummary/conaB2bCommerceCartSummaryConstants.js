import defaultErrorMessage from '@salesforce/label/c.CONA_B2BDefaultErrorMessage';
import effectiveAccountNotFound from '@salesforce/label/c.CONA_B2BEffectiveAccountNotFound';
import insufficientAccess from '@salesforce/label/c.CONA_B2BInsufficientAccess';
import invalidInput from '@salesforce/label/c.CONA_B2BInvalidInput';
import webstoreNotFound from '@salesforce/label/c.CONA_B2BWebstoreNotFound';
import cartButton from '@salesforce/label/c.CONA_B2BCartButtonLabel';
import checkoutButton from '@salesforce/label/c.CONA_B2BCheckoutButtonLabel';
import CONA_B2BpromoDiscountMsg from '@salesforce/label/c.CONA_B2BPromoDiscountMsgLabel';
import promoSaved from '@salesforce/label/c.CONA_B2BPromoSavedLabel';

export const REPRICED_EVENT_NAME = 'repricing';
export const ORDER_CHARGE_EVENT_NAME = 'orderchargeapplied';
export const MISSING_RECORD = 'MISSING_RECORD';
export const MOV_CONDITION_TYPE = 'ZMOV';
export const MOQ_CONDITION_TYPE = 'ZMOQ';
export const SET_AMOUNT_IN_IFRAME = 'setamountoniframe';
export const ORDER_ORIGIN_ECOM = 'ECOM';
export const SALES_DOC_ZOR = 'ZOR';
export const FIELDS = ['WebStore.Id', 'WebStore.BottlerId__c'];

export const LABELS = {
    defaultErrorMessage: defaultErrorMessage,
    effectiveAccountNotFound: effectiveAccountNotFound,
    insufficientAccess: insufficientAccess,
    invalidInput: invalidInput,
    webstoreNotFound: webstoreNotFound,
    cartButton: cartButton,
    checkoutButton: checkoutButton,
    promoDiscountMsg: CONA_B2BpromoDiscountMsg,
    promoSaved: promoSaved
};

export const ITEM_FIELD_MAPPING = new Map([
    ['itemNumber', 'productDetails.sku'],
    ['material', 'productDetails.fields.ProductCode'],
    ['requestedQuantity', 'quantity'],
    ['requestedQuantityUom', 'productDetails.fields.QuantityUnitOfMeasure']
]);