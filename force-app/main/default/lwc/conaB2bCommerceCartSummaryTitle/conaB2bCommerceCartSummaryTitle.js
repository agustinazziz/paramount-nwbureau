import {LightningElement, api} from 'lwc';
import {format} from 'c/conaB2BUtil';
import LABELS from './conaB2bCommerceCartSummaryTitleConst';

export default class ConaB2BCommerceCartSummaryTitle extends LightningElement {

    uniqueProductCount = 0;

    totalProductCount = 0;

    labels

    @api
    get cartSummary() {
        return this._cartSummary;
    }

    set cartSummary(value) {
        this._cartSummary = value;
        this.setTotals();
    }

    _cartSummary;

    setTotals() {
        if(this._cartSummary) {
            const {uniqueProductCount, totalProductCount} = this._cartSummary;
            this.uniqueProductCount = parseInt((uniqueProductCount || 0), 10);
            this.totalProductCount = parseInt((totalProductCount || 0), 10);
        }
    }

    get title() {
        return LABELS.TITLE;
    }

    get titleTotals() {
        return format(LABELS.TITLE_TOTALS, [this.uniqueProductCount, this.totalProductCount ]);
    }
}