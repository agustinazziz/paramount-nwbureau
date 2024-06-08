import { LightningElement, api, track, wire } from 'lwc';
import { navigate, NavigationContext } from 'lightning/navigation';
import Toast from 'lightning/toast';
import { exportCSVFile } from 'c/conaB2BUtil';
import { updateItemInCart, deleteItemFromCart, deleteCurrentCart, refreshCartSummary } from 'commerce/cartApi';
import {
    LABELS,
    CART_ACTION_PROCESSING,
    CART_DP_ACTION_SHOW_MORE,
    SORT_BY_FIELDS,
    ITEM_PRICING_KEY,
    RESET_REPRICING_EVENT,
    ITEM_INVENTORY_KEY,
    OUT_OF_STOCK,
    ITEM_VALIDITY_KEY,
    NAVIGATE_TO_CHECKOUT,
    INVALID_ITEM_EVENT,
    NAME,
    FETCH_PRICES_CHECKOUT,
    QUANTITY,
    ITEM_PRICE,
    INVOICE_AMOUNT,
    SKU,
    UPC,
    CART_EXPORT
} from './conaB2BCommerceCartItemsConstants';
import icons from '@salesforce/resourceUrl/conaB2BImages';
import { clearCartConfirmation, cartItemsMenuBar, sortDataByColumn, getFieldValue, outOfStockWarning, outOfAmlWarning, outOfStockAndOutOfAmlWarning, orderChargeLabels, modalAlertWarning, cartSummaryLabels, BacktoCartlabel } from 'c/conaB2BUtil';
import getProductInventoryDetails from '@salesforce/apex/ConaB2B_CommerceCartItemsCntrl.getProductInventoryStatus';
import savePriceOnCartItem from '@salesforce/apex/ConaB2B_CommerceCartItemsCntrl.updatePriceOnCartItem';
import getItemDiscount from '@salesforce/apex/ConaB2B_CommerceCartItemsCntrl.getPromoPriceById'; 
import getEasyOrderRecommendations from '@salesforce/apex/ConaB2B_CommerceCartItemsCntrl.getRecommendationSourceById'; /// ::: labels EO defect :::||
import getValidProducts from '@salesforce/apex/CONA_B2BAMLController.validateProductsInAML';
import getCartItems from '@salesforce/apex/ConaB2B_CommerceCartItemsCntrl.getCurrentCartItems';
import { getAppContext } from 'commerce/contextApi';
import { getRecord } from 'lightning/uiRecordApi';
import { ProductCategoryHierarchyAdapter } from 'commerce/productApi';
import { NavigationMixin } from 'lightning/navigation';
import { effectiveAccount } from 'commerce/effectiveAccountApi';
import CONA_B2BContinueShopping from '@salesforce/label/c.CONA_B2BContinueShopping';
import analyticsUtil from 'c/conaB2BAnalyticsUtil';
import saveToShoppingListModal from 'c/conaB2BSaveProductToShoppingList';

const FIELDS = ['WebStore.Id', 'WebStore.Enable_Inventory__c', 'WebStore.BottlerId__c'];
const MOV_CONDITION_TYPE = 'ZMOV';
const MOQ_CONDITION_TYPE = 'ZMOQ';
/**
 * @slot showMore ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: { text: "Show More", textDisplayInfo: "{\"textStyle\": \"body-regular\"}" }}] })
 */
export default class ConaB2BCommerceCartItems extends NavigationMixin(LightningElement) {
    CONA_B2BContinueShopping = CONA_B2BContinueShopping;
    deleteIcon = icons + '/conaB2BImages/deleteicon.png';
    saveToShoppingIcon = icons + '/conaB2BImages/saveicon.png';
    exportIcon = icons + '/conaB2BImages/exporticon.png';
    clearCartIcon = icons + '/conaB2BImages/carticon.png';
    warningIcon = icons + '/conaB2BImages/warningicon.png';
    orderChargeWarningIcon = icons + '/conaB2BImages/orderchargewarningicon.png';
    closeicon = icons + '/conaB2BImages/closeicon.png';
    clearCartConfirmationLabels = clearCartConfirmation;
    outOfStockWarningLabels = outOfStockWarning;
    outOfAmlWarningLabels = outOfAmlWarning;
    outOfStockAndOutOfAmlWarningLabels = outOfStockAndOutOfAmlWarning;
    cartItemsMenuBar = cartItemsMenuBar;
    orderChargeLabels = orderChargeLabels;
    modalAlertWarningLabel = modalAlertWarning;
    cartSummaryLabels = cartSummaryLabels;
    backtoCartlabel = BacktoCartlabel;
    analytics = analyticsUtil;
    csvHeaders = {
        name: NAME,
        quantity: QUANTITY,
        priceUnit: ITEM_PRICE,
        totalAmount: INVOICE_AMOUNT,
        sku: SKU,
        upc: UPC
    };
    /**
     * An event fired when an action is dispatched to the data provider
     *
     * Properties:
     *   - Bubbles: true
     *   - Cancelable: false
     *   - Composed: true
     *
     * @event CartItems#cartactionprocessing
     * @type {CustomEvent}
     * @property {{processing: boolean, loadingData?: boolean}} detail isProcessing
     *
     * @export
     */

    /**
     * Enable the component to render as light DOM
     *
     * @static
     */
    static renderMode = 'light';

    isLoading = false;

    isInventoryInfoLoaded = false;

    isValidCheckCompleted = false;

    outOfStockCount = 0;
    outOfAlmCount = 0;
    hideAlertOosAmlFlag = false;

    @track validSkuList = [];

    /**
     * Gets the AccountId value for Current user
     */
    effectiveAccountId = effectiveAccount.accountId;

    /**
     * @description List of cart items from the data provider
     */
    @api items;

    cartItems;

    /**
     * sorted items
     */
    @track sortedItems;

    /**
     * @description Boolean to enable/disable inventory check
     */
    isInventoryCheckEnabled;

    isCheckoutButtonDisabled = false;

    selectedItems = [];

    /**
     * ToDo -  Remove this from experience bundle
     */

    @api enableInventoryCheck;
    bottlerId;
    isDisabled = true;
    connectedCallback() {
        this.getWebstoreIdFromAppContext();
        this.addEventListener('click', () => {
            let itemsToRemove = this.querySelector('c-cona-b2-b-cart-items')?.getSelectedCartItemIds();
            if (itemsToRemove && itemsToRemove.length === 0) {
                this.querySelector('.pointer').classList = 'pointer pointer-cursordis slds-grid slds-wrap';
                this.isDisabled = true;
            } else {
                this.querySelector('.pointer').classList = 'pointer pointer-cursor slds-grid slds-wrap';
                this.isDisabled = false;
            }
        });
    }
    renderedCallback() {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            let header = document.querySelector('header > commerce_cart-header');
            if (header) {
                header.style.border = 'none';
}
        }, 200);

        let b = document.querySelectorAll('dxp_base-text-block > h6');
        if (b.length > 0) {
            for (let i = 0; i < b.length; i++) {
                b[i].classList.add('fontstyle');
            }
        }
    }

    /**
     * feeding data to ui
     */
    get _items() {    
        if (!this.sortedItems || this.sortedItems.length !== this.cartItems.length) {
                let items = [];
                this.cartItems.forEach((item) => {
                let itemClone = JSON.parse(JSON.stringify(item));
                if (this.isInventoryCheckEnabled && this.productInventoryMap) {
                    let key = getFieldValue(ITEM_INVENTORY_KEY, item);
                    let statusObject = this.productInventoryMap.find((element) => element.productIdentifier === key);
                    itemClone.inventoryStatus = statusObject ? statusObject.inventoryStatus : '';
                }
                if (this.promoDiscountByItem && this.promoDiscountByItem.length > 0) {
                    let promoDiscountObj = this.promoDiscountByItem.find((element) => element.cartItemId === item.cartItemId);
                    if (promoDiscountObj) {
                        itemClone.promoDiscount = promoDiscountObj.promoDiscount;
                    }
                }                
                itemClone.recommendationSourceLabel = '';
                itemClone.recommendationSource = '';

                if (this.easyOrderRecommendationByItem) {
                  let easyOrderRecommendationObject =
                    this.easyOrderRecommendationByItem.find((element) => element.cartItemId === item.cartItemId);
                  if (easyOrderRecommendationObject) {
                      itemClone.recommendationSourceLabel = easyOrderRecommendationObject.recommendationSourceLabel;
                      itemClone.recommendationSource = easyOrderRecommendationObject.recommendationSource;
                  }
                }
                items.push(itemClone);
            });
                this.sortedItems = items;
                this.sortedItems.forEach((element) => {
                    element.isvalidproduct = this.validSkuList.includes(getFieldValue(ITEM_VALIDITY_KEY, element));
                });
        } else {
            this.refreshSortedItems();
        }

        return this.sortedItems;
    }

    refreshSortedItems() {
        if (this.sortedItems) {
            this.sortedItems = this.sortedItems.map((sortedItem) => {
                const foundItem = this.cartItems.find((item) => item.cartItemId === sortedItem.cartItemId);

                if (foundItem) {
                    const _sortedItem = { ...sortedItem };
                    _sortedItem.quantity = foundItem.quantity;
                    _sortedItem.isSelected = sortedItem.isSelected;
                    
                    if (this.isInventoryCheckEnabled) {
                        let key = getFieldValue(ITEM_INVENTORY_KEY, _sortedItem);
                        let statusObject = this.productInventoryMap.find((element) => element.productIdentifier === key);
                        _sortedItem.inventoryStatus = statusObject ? statusObject.inventoryStatus : '';
                    }

                    _sortedItem.isvalidproduct = this.validSkuList?.length > 0 ? this.validSkuList.includes(getFieldValue(ITEM_VALIDITY_KEY, _sortedItem)) : false;

                    return _sortedItem;
                }

                return sortedItem;
            });
        }
    }

    get _activeItems() {
        let availableItems = [];
        this._items.forEach((element) => {
            element.sku = element.productDetails.sku;
            element.upc = element.productDetails.fields.EANUPC__c;
            element.name = element.productDetails.fields.B2B_Product_Name__c;
            if (this.isInventoryCheckEnabled) {
                if (element.inventoryStatus !== OUT_OF_STOCK && element.isvalidproduct) {
                    availableItems.push(element);
                }
            } else {
                if (element.isvalidproduct) {
                    availableItems.push(element);
                }
            }
        });
        return availableItems;
    }

    get _inactiveItems() {
        let inactiveItems = [];
        let oosCount = 0;
        let almCount = 0;
        this._items.forEach((element) => {
            if ((this.isInventoryCheckEnabled && element.inventoryStatus === OUT_OF_STOCK) || !element.isvalidproduct) {
                inactiveItems.push(element);
                if(element.isvalidproduct) {
                    if(element.inventoryStatus === OUT_OF_STOCK) {
                        oosCount += 1;
                    }     
                } else {
                    almCount +=1;
                }
            }
        });
        this.outOfStockCount = oosCount;
        this.outOfAlmCount = almCount;
        let invalidItemPresent = inactiveItems.length > 0 ? true : false;
        const selectedEvent = new CustomEvent(INVALID_ITEM_EVENT, {
            detail: {
                invalidItemPresent
            },
            bubbles: true
        });
        this.dispatchEvent(selectedEvent);
        return inactiveItems;
    }

    get showCartItem() {
        return this.isInventoryCheckEnabled ? this.isInventoryInfoLoaded : this.isValidCheckCompleted && this._items.length;
    }

    get showInactiveSection() {
        return this.isInventoryCheckEnabled
            ? this.isInventoryInfoLoaded && this._inactiveItems.length > 0
            : this.isValidCheckCompleted && this._inactiveItems.length > 0;
    }

    @api
    async refreshItemsOnCart() {
        this.isLoading = true;
        await this.identifyValidSkus();
        if (this.hasAlerts || this.showOrderChargeModal) {
            if(this._inactiveItems?.length === this.cartItems?.length) {
                this.isCheckoutButtonDisabled = true;
            } else {
                this.isCheckoutButtonDisabled = false;
            }
            this._alertModal.showModal();    
        } else {
            const selectedEvent = new CustomEvent(NAVIGATE_TO_CHECKOUT, {bubbles:true});
            this.dispatchEvent(selectedEvent);
        }
        this.hideAlertOosAmlFlag = false;
        this.isLoading = false;
    }

    async handleModalProceedToCheckout(){
        const selectedModalEvent = new CustomEvent(FETCH_PRICES_CHECKOUT, {bubbles:true});
        this.dispatchEvent(selectedModalEvent);
     }

     @api
    async  validateDeleteInvalidItems() {
        this.isLoading = true;
        await this.identifyValidSkus();
        if (this.hasAlerts || this.showOrderChargeModal) {
            if(this._inactiveItems?.length === this.cartItems?.length) {
                this.isCheckoutButtonDisabled = true;
            } else {
                this.isCheckoutButtonDisabled = false;
                this.dispatchActionProcessing(true);
                const deletePromisses = [];
                this._inactiveItems.forEach(async item => {
                    deletePromisses.push(await deleteItemFromCart(item.cartItemId));
                });
                if(deletePromisses?.length > 0) {
                    await Promise.all(deletePromisses)
                    .then(async (result) => await refreshCartSummary())
                    .catch((error) => console.log(error));                    
                }
                this.dispatchActionProcessing(false);
                const selectedEvent = new CustomEvent(NAVIGATE_TO_CHECKOUT, {bubbles:true});
                this.dispatchEvent(selectedEvent);
            }
        }
        this.hideAlertOosAmlFlag = false;
        this.isLoading = false;
     }
    /**
     * @description Counter for oos items
     */
    get oosAlert() {
        return this.outOfStockCount > 0;
    }

    /**
     * @description Counter for aml items
     */
    get amlAlert() {
        return this.outOfAlmCount > 0;
    }

    /**
     * @description Flag to show oos alert or aml alert
     */
    get hasAlerts () {
        return this.oosAlert || this.amlAlert;
    }

    /**
     * @description Flag to show oos alert or aml alert
     */
    get showAlertOosAmlFlag () {
        return !this.hideAlertOosAmlFlag && (this.oosAlert || this.amlAlert);
    }

    /**
     * @description Warning header message to display
     */
    get alertWarningHeader() {
        return this.oosAlert && this.amlAlert ? this.outOfStockAndOutOfAmlWarningLabels.outOfStockAndOutOfAmlHeader : this.oosAlert ? this.outOfStockWarningLabels.outOfStockWarningHeader : this.amlAlert ? this.outOfAmlWarningLabels.outOfAmlWarningHeader : undefined;
    }
    
    /**
     * @description Warning message to display
     */
    get alertWarningMessage() {
        return this.oosAlert && this.amlAlert ? this.outOfStockAndOutOfAmlWarningLabels.outOfStockAndOutOfAmlMessage : this.oosAlert ? this.outOfStockWarningLabels.outOfStockWarningMessage : this.amlAlert ? this.outOfAmlWarningLabels.outOfAmlWarningMessage : undefined;
    }
    
    /**
     * @description Is there a next page of items
     */
    @api hasNextPageItems = false;
    /**
     * @description User defined option to show or hide the "show more" button/link
     */
    @api displayShowMoreItems = false;

    /**
     * @description Always display the "Show More" button if in the builder or if displayShowMore === true
     * @readonly
     */
    get displayShowMoreButton() {
        return this.displayShowMoreItems ? this.hasNextPageItems : false;
    }

    /**
     * @description Currency ISO code for the cart
     */
    @api currencyIsoCode;

    get _currencyIsoCode() {
        return this.currencyIsoCode;
    }

    /**
     * @description Show the "Remove Items" link
     */
    @api showRemoveItem = false;

    /**
     * @description Show the product image
     */
    @api showProductImage = false;

    /**
     * @description Show variant information
     */
    @api showProductVariants = false;

    /**
     * @description Show the price per unit
     */
    @api showPricePerUnit = false;

    /**
     * @description Custom font color for price per unit
     */
    @api pricePerUnitFontColor;
    /**
     * @description Custom font size for price per unit
     */
    @api pricePerUnitFontSize;

    /**
     * @description Show the total price column, which includes the original and actual prices
     */
    @api showTotalPrices = false;

    /**
     * @description Show the original price
     */
    @api showOriginalPrice = false;

    /**
     * @description Custom font color for original price
     */
    @api originalPriceFontColor;

    /**
     * @description Custom font size for original price
     */
    @api originalPriceFontSize;

    /**
     * @description Show the actual price
     */
    @api showActualPrice = false;
    /**
     * @description Custom font color for actual price
     */
    @api actualPriceFontColor;
    /**
     * @description Custom font size for actual price
     */
    @api actualPriceFontSize;

    /**
     * @description Show the promotions/discounted price
     */
    @api showPromotions = false;

    /**
     * @description discount/applied promotions button text - takes '{amount}' as a replaceable parameter
     */
    @api promotionsAppliedSavingsButtonText;

    /**
     * @description discount/applied promotions button font color
     */
    @api promotionsAppliedSavingsButtonFontColor;

    /**
     * @description discount/applied promotions button font size
     */
    @api promotionsAppliedSavingsButtonFontSize;

    /**
     * @description discount/applied promotions button hover text color
     */
    @api promotionsAppliedSavingsButtonTextHoverColor;

    /**
     * @description discount/applied promotions button background color
     */
    @api promotionsAppliedSavingsButtonBackgroundColor;

    /**
     * @description discount/applied promotions button background hover color
     */
    @api promotionsAppliedSavingsButtonBackgroundHoverColor;

    /**
     * @description discount/applied promotions button border color
     */
    @api promotionsAppliedSavingsButtonBorderColor;

    /**
     * @description discount/applied promotions button border radius
     */
    @api promotionsAppliedSavingsButtonBorderRadius;

    /**
     * @description Show the product SKU
     */
    @api showSku = false;

    /**
     * @description Label for sku field
     */
    @api skuLabel;

    /**
     * @description text that shows up in a quantity rules popover; takes '{0}' as a replaceable parameter
     */
    @api minimumValueGuideText;

    /**
     * @description text that shows up in a quantity rules popover; takes '{0}' as a replaceable parameter
     */
    @api maximumValueGuideText;

    /**
     * @description text that shows up in a quantity rules popover; takes '{0}' as a replaceable parameter
     */
    @api incrementValueGuideText;

    /**
     * @description List of other custom fields to be displayed, as a JSON string
     */
    @api productFieldMapping;

    /**
     * @description List of other custom fields to be displayed, as a JSON string
     */
    productFieldsForSort = SORT_BY_FIELDS;

    /**
     * the column selected for sort
     */

    sortedBy;

    webstoreId;

    promoDiscountByItem;

    easyOrderRecommendationByItem;

    /**
     * sort direction; either `asc` or `desc`
     */

    sortedDirection;

    /**
     * @description attribute to store Inventory Info by product
     */
    productInventoryMap;

    orderChargeHeaderLabel;
    orderChargeMessageLabel;
    showOrderChargeModal = false;
    alertOrderChargeFlag = false;
    categoryId;

    /**
     * @description Convert the custom fields string into an array
     * @readonly
     */
    get productFieldMappingValue() {
        return this.productFieldMapping ? JSON.parse(this.productFieldMapping) : [];
    }
    /**
     * Gets the 'clear-cart-dialog' element ( clear cart )
     * @readonly
     * @private
     */
    get _clearCartModal() {
        return this.querySelector('c-cona-b2-b-dialog.clear-cart__modal');
    }

    get _alertModal() {
        return this.querySelector('c-cona-b2-b-dialog.alert-modal__container');

    }

    @wire(ProductCategoryHierarchyAdapter, {
        effectiveAccountId: '$effectiveAccountId'
    })
    wiredCategories({ data, error }) {
        if (data) {
            this.categoryId = data.productCategories[0].fields.Id;
        } else {
            this.error = error;
        }
    }

    @wire(getRecord, { recordId: '$webstoreId', fields: FIELDS })
    wiredWebstore({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.isInventoryCheckEnabled = data.fields.Enable_Inventory__c?.value;
            this.bottlerId = data.fields.BottlerId__c?.value;
            this.identifyValidSkus();
            this.getEasyOrderRecommendationForItems();
        }
    }

    async identifyValidSkus() {
        let skuList = [];
        this.cartItems.forEach((element) => {
            skuList.push(getFieldValue(ITEM_VALIDITY_KEY, element));
        });
        await getValidProducts({ skus: skuList, accountId: this.effectiveAccountId }).then(async (result) => {
            this.validSkuList = result;
            this.isValidCheckCompleted = true;            
            await this.getDiscountAmountForItems();
            
        });
    }

    async getDiscountAmountForItems() {
        let idList = [];
        this.cartItems.forEach((element) => {
            idList.push(element.cartItemId);
        });
        await getItemDiscount({ itemIdList: idList }).then(async (result) => {
            this.promoDiscountByItem = result;
            if (this.isInventoryCheckEnabled) {
                await this.getInventoryDetailForItems(this.cartItems);
            } else {
                this.isLoading = false;
            }
        });
    }
    
    async getEasyOrderRecommendationForItems() {
        let idList = [];
        this.cartItems.forEach((element) => {
            idList.push(element.cartItemId);
        });
        await getEasyOrderRecommendations({ bottlerId: this.bottlerId, itemIdList: idList }).then((result) => {            
            this.easyOrderRecommendationByItem = result;
        });
    }
   
    async getInventoryDetailForItems(cartItems) {
        let proudctMaterialList = [];
        cartItems.forEach((element) => {
            proudctMaterialList.push(getFieldValue(ITEM_INVENTORY_KEY, element));
        });
        await getProductInventoryDetails({ productIdentifiers: proudctMaterialList, effectiveAccountId: this.effectiveAccountId }).then((result) => {
            this.productInventoryMap = result;
            this.isInventoryInfoLoaded = true;
            this.isLoading = false;

            try {
                console.log(`getInventoryDetailForItems---- activeItems: `, this._activeItems);

                this.analytics.viewCart(null, this._items, this.currencyIsoCode);
            } catch (error) {
                console.log(`:/ Analytics error - `, error);
            }
        });
    }

    updateCartItemRecords(cartItems) {
        this.isLoading = true;
        savePriceOnCartItem({ items: cartItems }).then((result) => {
            this.isLoading = false;
        });
    }

    getWebstoreIdFromAppContext() {
        this.isLoading = true;
        getAppContext().then((result) => {
            this.getAllCartItems(result.webstoreId, true);
        });
    }

    /**
     * Gets the price details from order simulate response
     */
    @api repriceItems(detail) {
        let pricingDetails = detail.item;
        let itemsWithPrice = [];
        let itemsToUpdate = [];
        let index = 0;
        this.sortedItems?.forEach((element) => {
            index += 1;
            let clonedElement = JSON.parse(JSON.stringify(element));
            let key = index * 10;
            let priceObject = pricingDetails.find((dataItem) => parseInt(dataItem.number) === parseInt(key));
            let itemNumer = priceObject ? priceObject.number : '';
            if (itemNumer) {
                let moqPrice = detail.condition.reduce((accumulator, currentCondition) => {
                    return accumulator + (currentCondition?.itemNumber === itemNumer && currentCondition?.type === MOQ_CONDITION_TYPE)
                        ? currentCondition
                            ? parseFloat(currentCondition?.value)
                            : 0
                        : 0;
                }, 0);
                let movPrice = detail.condition.reduce((accumulator, currentCondition) => {
                    return accumulator + (currentCondition?.itemNumber === itemNumer && currentCondition?.type === MOV_CONDITION_TYPE)
                        ? currentCondition
                            ? parseFloat(currentCondition?.value)
                            : 0
                        : 0;
                }, 0);
                if (priceObject) {
                    clonedElement.totalAmount = parseFloat(priceObject?.subTotal);
                    clonedElement.promoDiscount = Math.abs(priceObject?.totalDiscounts);
                    clonedElement.totalFees = priceObject?.totalFees;
                    clonedElement.totalDeposits = priceObject?.totalDeposits;
                    clonedElement.totalTaxes = priceObject?.totalTaxes;
                    clonedElement.totalPriceActual = priceObject?.totalPrice;
                    clonedElement.moqFees = moqPrice;
                    clonedElement.movFees = movPrice;
                }

                let itemToUpdate = {
                    cartItemId: clonedElement.cartItemId,
                    totalPrice: clonedElement.totalAmount,
                    promoDiscount: clonedElement.promoDiscount,
                    totalFees: clonedElement.totalFees,
                    totalDeposits: clonedElement.totalDeposits,
                    totalTaxes: clonedElement.totalTaxes,
                    totalPriceActual: clonedElement.totalPriceActual,
                    moqFees: clonedElement.moqFees,
                    movFees: clonedElement.movFees
                };
                clonedElement.totalAmount = clonedElement.totalAmount - clonedElement.promoDiscount;
                itemsWithPrice.push(clonedElement);
                itemsToUpdate.push(itemToUpdate);
            }
        });
        this.updateCartItemRecords(itemsToUpdate);
        this.sortedItems = itemsWithPrice;
        
        try {
            this.analytics.saveCartItemPrices(this._activeItems);
        } catch (error) {
            console.log(`:/ Analytics error - `, error);
        }
    }

    @api processOrderChargeEvent(eventDetails) {
        if (eventDetails.chargeType === 'MOV') {
            this.orderChargeHeaderLabel = this.orderChargeLabels.movLabel;
        } else if (eventDetails.chargeType === 'MOQ') {
            this.orderChargeHeaderLabel = this.orderChargeLabels.moqLabel;
        } else {
            this.showOrderChargeModal = false;
            this.alertOrderChargeFlag = false;
            return;
        }
        this.orderChargeMessageLabel = this.orderChargeLabels.orderChargeMsgLable.replace('{0}', this.orderChargeHeaderLabel.toLowerCase());
        this.showOrderChargeModal = true;
        this.alertOrderChargeFlag = true;
    }

    handleNavigateToProductListPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'ProductCategory',
                recordId: this.categoryId,
                actionName: 'view'
            }
        });
    }

    /**
     * handleer for triggering sort action on field selection
     */
    handleSortSelect(event) {
        this.refreshSelectedItem();
        let colName = event.detail.value;
        if (this.sortedBy === colName) {
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortedDirection = 'asc';
        }
        this.sortedBy = colName;
        if (!this.sortedItems) {
            this.sortedItems = JSON.parse(JSON.stringify(this.cartItems));
        }
        this.sortedItems = sortDataByColumn(this.sortedItems, colName, this.sortedDirection);
        this.sortedItems.forEach((ele) => {
            ele.isSelected = this.selectedItems.includes(ele.cartItemId);
        });
    }

    /**
     * Handler for the 'click' event fired from the clear cart button
     * which should show the clear cart modal ( Mobile & Desktop )
     *
     * @private
     */
    handleClearCartButtonClicked() {
        this._clearCartModal.showModal();
    }

    /**
     * Handler for the 'click' event fired from the 'cancel' button, (clear cart modal)
     * which should close the clear cart modal ( Mobile & Desktop )
     *
     * @private
     */
    handleModalCancelButtonClicked() {
        this._clearCartModal.close();
    }

    /**
     * Handler for the 'click' event fired from the 'Back to cart' button, (from alert modal)
     * which should close alert modal 
     *
     * @private
     */
    handleBackToCart(event) {
        event.stopPropagation();
        this._alertModal.close();
        this.isCheckoutButtonDisabled = false;
    }

    /**
     * Handler for the 'cancel' event fired from the 'Close' icon, (from alert modal)
     * which should reset the disabel proced to checkout button status 
     *
     * @private
     */
    handleCancelAlertModal(event) {
        event.stopPropagation();
        this.isCheckoutButtonDisabled = false;
    }

    /**
     * Fires an event that requests to clear the cart
     * @private
     * @fires Contents#clearcart
     */
    handleModalClearCartButtonClicked() {
        this.dispatchActionProcessing(true);
        deleteCurrentCart();
        this.dispatchActionProcessing(false);
        this._clearCartModal.close();
    }

    /**
     * @description Handle the 'cartshowmore' event and fire the appropriate action to the data provider
     */
    handleCartShowMore() {
        this.dispatchActionProcessing(true);
        this.dispatchEvent(new CustomEvent(CART_DP_ACTION_SHOW_MORE, undefined));
        this.dispatchActionProcessing(false, false);
    }

    /**
     * @description Handle the 'deletecartitem' event and fire the appropriate action to the data provider
     * @param {CustomEvent} event
     * @param {string} event.detail
     */

    async handleDeleteCartItem(event) {
        if (this.cartItems.length === 1) {
            this.dispatchActionProcessing(true);
            await deleteCurrentCart();
            this.dispatchActionProcessing(false);
            return;
        }
        this.isLoading = true;
        this.refreshSelectedItem();
        this.dispatchActionProcessing(true);
        await deleteItemFromCart(event.detail);
        this.triggerResetRepricing();
        this.refreshItemsInCart();
        this.dispatchActionProcessing(false);
    }
    /**
     * @description
     * @param {CustomEvent} event
     * @param {{ cartItemId: string, quantity: number }} event.detail
     */
    handleUpdateCartItem(event) {
        const cartItemId = event.detail.cartItemId;

        if (event.detail.refreshOnlyLocally) {
            this.sortedItems.forEach((sortedItem) => {
                if (sortedItem.cartItemId === cartItemId) {
                    sortedItem.isSelected = event.detail.isSelected;
                }
            });
        } else {
            this.refreshSelectedItem();
            this.dispatchActionProcessing(true);
            updateItemInCart(cartItemId, event.detail.quantity);
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                this.triggerResetRepricing();
                this.dispatchActionProcessing(false);
                this.refreshItemsInCart();
            }, 1000);
        }
    }

    /**
     * @description send event to reset repricing flag
     */
    triggerResetRepricing() {
        this.showOrderChargeModal = false;
        this.alertOrderChargeFlag = false;
        this.isLoading = true;
        const selectedEvent = new CustomEvent(RESET_REPRICING_EVENT, { bubbles: true });
        this.dispatchEvent(selectedEvent);
        this.isLoading = false;
    }

    @wire(NavigationContext)
    navContext;

    /**
     * @description Handle the 'navigatetoproduct'
     * @param {CustomEvent} event
     * @param {string} event.detail
     */
    handleProductNavigation(event) {
        navigate(this.navContext, {
            type: 'standard__recordPage',
            attributes: {
                objectApiName: 'Product2',
                recordId: event.detail,
                actionName: 'view'
            }
        });
    }

    /**
     * @description
     * @private
     * @param {boolean} processing This tells parent components if the action is still pending
     * @param {(boolean | undefined)} [loadingData=undefined] This tells parent components if the data
     * is still loading.  This is need if the parent cannot tell if new data has loaded because the setter is not
     * triggered.
     */
    dispatchActionProcessing(processing, loadingData = undefined) {
        this.dispatchEvent(
            new CustomEvent(CART_ACTION_PROCESSING, {
                detail: {
                    processing,
                    loadingData
                },
                bubbles: true,
                composed: true
            })
        );
    }

    /**
     * @description
     * This is used to delete the selected items from cart
     * @param {CustomEvent} event
     */
    async removeSelectedItems(event) {
        let cartItems = this.querySelector('c-cona-b2-b-cart-items').getSelectedCartItemIds();
        if (cartItems.length > 0) {
            if (cartItems.length === this.cartItems.length) {
                this.dispatchActionProcessing(true);
                deleteCurrentCart();
                this.dispatchActionProcessing(false);
                return;
            }
            this.isLoading = true;
            this.refreshSelectedItem();
            this.dispatchActionProcessing(true);
            for (let index = 0; index < cartItems.length; index++) {
                const element = cartItems[index];
                await deleteItemFromCart(element);
            }
            this.isLoading = false;
            this.triggerResetRepricing();
            this.refreshItemsInCart();
            this.dispatchActionProcessing(false);
        }
    }

    handleCloseOrderChargeModal() {
        this.alertOrderChargeFlag = false;
    }
    handleCloseOosAndAmlAlerts() {
        this.hideAlertOosAmlFlag  = true;
    }

    handleExport() {
        const selectedCartItems = (this.getSelectedCartItems() || []).map((selectedCartItem) => {
           const _selectedCartItem = { ...selectedCartItem };
           const priceUnit = (_selectedCartItem.totalAmount || 0) / (_selectedCartItem.quantity || 1);

           _selectedCartItem.priceUnit = this.roundToTwoDecimalPlaces(priceUnit);

           return _selectedCartItem;
        });

        if (selectedCartItems && selectedCartItems.length > 0) {
            exportCSVFile(this.csvHeaders, selectedCartItems, CART_EXPORT);
        } else {
            this.showErrorToast(LABELS.SELECT_AT_LEAST_ONE_RECORD_EXPORT_CSV_ERROR);
        }
    }

    roundToTwoDecimalPlaces(num) {
        return (Math.round(((num || 0) + Number.EPSILON) * 100) / 100).toFixed(2);
    }

    getSelectedCartItems() {
        const cartItemsElem = this.querySelector('.active-cart-items');

        if (cartItemsElem) {
            const selectedCartItemIds = cartItemsElem.getSelectedCartItemIds();

            if (selectedCartItemIds && selectedCartItemIds.length > 0) {
                return this._activeItems.filter((activeItem) => selectedCartItemIds.includes(activeItem.cartItemId));
            }
        }

        return [];
    }
    async getAllCartItems(webstore, updateWebStore) {
        await getCartItems({ webstoreId: webstore, effectiveAccountId: this.effectiveAccountId })
            .then(async (result) => {
                const deletePromisses=[];
                const cartItems =[];
                result?.forEach(async (ele) => {
                    if(!ele.productDetails.sku) {
                        deletePromisses.push(await deleteItemFromCart(ele.cartItemId));
                    } else {
                        cartItems.push({...ele, isSelected: this.selectedItems.includes(ele.cartItemId)});
                    }
                });
                this.cartItems = cartItems;
                if(deletePromisses?.length > 0) {
                    await Promise.all(deletePromisses)
                    .then(async (result) => await refreshCartSummary())
                    .catch((error) => console.log(error));
                }
                if (updateWebStore) {
                    this.webstoreId = webstore;
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }
    refreshItemsInCart() {
        this.getAllCartItems(this.webstoreId, false);
    }

    refreshSelectedItem() {
        this.selectedItems = this.querySelector('c-cona-b2-b-cart-items')?.getSelectedCartItemIds() || [];
    }

    showErrorToast(message) {
        const toast = {
            label: message,
            variant: 'error',
            mode: 'dismissible'
        };

        Toast.show(toast, this);
    }
    /**
     * @description collects all products id in cart and sends list to save to shopping list modal
     */
    async openSaveToShoppingListModal() {
        let recordIdList = [];
        this.cartItems.forEach((ele) => {
            recordIdList.push(ele.productDetails.productId);
        });
        await saveToShoppingListModal.open({
            size: 'small',
            productIds: recordIdList
        });
    }
}