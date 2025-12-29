import { LightningElement, api, track, wire } from 'lwc';
import getLeadRecord from '@salesforce/apex/LeadToCaseController.getLeadRecord';
import getCasePicklistValues from '@salesforce/apex/LeadToCaseController.getCasePicklistValues';
import createCaseFromLead from '@salesforce/apex/LeadToCaseController.createCaseFromLead';

import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import BUSINESS_REGION_FIELD from '@salesforce/schema/Lead.Business_Region__c';

export default class CreateCaseFromLead extends LightningElement {
    @api recordId;

    @track isLoading = false;

    @track status = 'New';
    @track type = 'Forward Lead';
    @track origin = 'Lead Conversion';
    @track priority = 'Medium';
    @track caseRecordType = 'None';
    @track businessRegion = '';
    @track subject = 'Internal Lead Forward';
    @track description = '';
    @track country = '';
    @track email = '';
    @track accountName = '';
    @track contactName = '';

    @track statusOptions = [];
    @track typeOptions = [];
    @track originOptions = [];
    @track priorityOptions = [];
    @track businessRegionOptions = [];

    @wire(getLeadRecord, { leadId: '$recordId' })
    wiredLead({ error, data }) {
        if (data) {
            this.contactName = data.Name;
            this.email = data.Email;
            this.businessRegion = data.Business_Region__c;
            this.description = data.Application_Detail__c;
            this.country = data.Country__c;

            if (this.email && this.email.includes('@')) {
                this.accountName = this.email.split('@')[1];
            }
        } else if (error) {
            console.error('Error fetching lead:', error);
        }
    }

    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT }) leadObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$leadObjectInfo.data.defaultRecordTypeId',
        fieldApiName: BUSINESS_REGION_FIELD
    })
    wiredBusinessRegion({ error, data }) {
        if (data) {
            this.businessRegionOptions = data.values.map(option => ({
                label: option.label,
                value: option.value
            }));
        }
    }

    connectedCallback() {
        getCasePicklistValues()
            .then(result => {
                this.statusOptions = result.Status.map(val => ({ label: val, value: val }));
                this.typeOptions = result.Type.map(val => ({ label: val, value: val }));
                this.originOptions = result.Origin.map(val => ({ label: val, value: val }));
                this.priorityOptions = result.Priority.map(val => ({ label: val, value: val }));
            })
            .catch(error => {
                console.error('Picklist error:', error);
            });
    }

    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
    }

    handleCaseRecordTypeChange(event) {
        this.caseRecordType = event.detail.value;
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleCreateCase() {
        if (!this.caseRecordType || this.caseRecordType === 'None') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Missing Record Type',
                    message: 'Please select a Case Record Type.',
                    variant: 'error'
                })
            );
            return;
        }

        this.isLoading = true;

        createCaseFromLead({
            leadId: this.recordId,
            caseRecordType: this.caseRecordType,
            status: this.status,
            type: this.type,
            contactName: this.contactName,
            email: this.email,
            accountName: this.accountName,
            businessRegion: this.businessRegion,
            subject: this.subject,
            description: this.description,
            origin: this.origin,
            priority: this.priority,
            country: this.country
        })
        .then(result => {
            const caseUrl = `/lightning/r/Case/${result.Id}/view`;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Case Created Please Click on CaseNumber {0} to view the details',
                    messageData: [
                        {
                            url: caseUrl,
                            label: result.CaseNumber
                        }
                    ],
                    variant: 'success',
                    mode: 'sticky'
                })
            );

            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
            console.error('Error creating case:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    get recordTypeOptions() {
        return [
            { label: '--- None ---', value: 'None' },
            { label: 'Customer Service', value: 'Customer Service' },
            { label: 'Tech Support', value: 'Tech Support' }
        ];
    }
}