/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, api, wire, track } from 'lwc';
import getAllFieldApis from "@salesforce/apex/ChartHelper.getAllFieldApis";
import getRecordData from "@salesforce/apex/ChartHelper.getRecordData";
import { loadScript } from 'lightning/platformResourceLoader';
import chart from "@salesforce/resourceUrl/chartJs";

export default class ChartsDemo extends LightningElement {

    @api objectApiName;
    @track fieldValue;
    @track options;
    // @track records;
    // @track dispmsg = 'testing';
    // @track columns = [
    //     { label: 'Age', fieldName: 'Age__c', type: 'text' }
    // ]
    @wire(getAllFieldApis, { obj: '$objectApiName' })
    fieldData({ error, data }) {
        if (error) {
            console.log(JSON.stringify(error));
        } else if (data) {
            let jsonData = '[' + data + ']';
            this.options = JSON.parse(jsonData);
            this.fieldValue = this.options[1].value;
        }
    }
    @track chartData = [];
    @track chartLabels = [];
    @track fieldLabel = '';
    @track chartType = '';
    @track scales = {};

    @wire(getRecordData, { obj: '$objectApiName', field: '$fieldValue' })
    recordsData({ error, data }) {
        if (error) {
            console.log(JSON.stringify(error));
        } else if (data) {
            let parsedData = JSON.parse(data)
            this.chartData = parsedData.data;
            this.chartLabels = parsedData.label;
            this.fieldLabel = parsedData.fieldLabel;
            this.chartType = parsedData.chartType;
            if (parsedData.chartType === 'pie'){
                this.scales = {};
            }
            else if(parsedData.chartType === 'bar'){
                this.scales = {
                    yAxes: [{
                        ticks: {
                            beginAtZero: true
                        }
                    }]
                };
            }
            this.renderChart();
        }
    }

    generateColors() {
        var bgColors = [];
        for (let i = 0; i < this.chartLabels.length; i++) {
            bgColors.push('#' + ((1 << 24) * Math.random() | 0).toString(16));
        }
        return bgColors;
    }

    renderedCallback() {
        Promise.all([
            loadScript(this, chart + '/Chart.js-2.8.0/dist/Chart.min.js')
        ]).then(() => {

        })
            .catch(error => {
                console.log('script load error : ' + error);
            });
    }

    handleChange(event) {
        this.fieldValue = event.detail.value;


    }


    renderChart() {
        var ctx = this.template.querySelector('.barChart');
        var myChart = [];
        // eslint-disable-next-line no-undef
        myChart = new Chart(ctx, {
            type: this.chartType,
            data: {
                labels: this.chartLabels,
                datasets: [
                    {
                        label: this.fieldLabel,
                        data: this.chartData,
                        backgroundColor: this.generateColors(),

                        borderColor: 'rgba(75, 192, 192, 1)',
                    }
                ]
            },
            options: {
                responsive: true,
                scales: this.scales

            }
        });
    }



}