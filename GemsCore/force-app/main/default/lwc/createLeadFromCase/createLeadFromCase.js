// JS - createLeadFromCase.js
import { LightningElement, api, track, wire } from 'lwc';
import getCaseRecord from '@salesforce/apex/CaseToLeadController.getCaseRecord';
import getLeadPicklistValues from '@salesforce/apex/CaseToLeadController.getLeadPicklistValues';
import createLeadFromCase from '@salesforce/apex/CaseToLeadController.createLeadFromCase';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreateLeadFromCase extends LightningElement {
    @api recordId;

    @track isLoading = false;
    @track name = '';
    @track email = '';
    @track company = '';
    @track status = 'Raw Lead';
    @track leadSource = '';
    @track businessRegion = '';
    @track businessUnit = '';
    @track applicationDetail = '';
    @track country = '';

    @track statusOptions = [];
    @track leadSourceOptions = [];
    @track businessRegionOptions = [];
    @track countryOptions = [];
   
    @wire(getCaseRecord, { caseId: '$recordId' })
    wiredCase({ error, data }) {
        if (data) {
            this.name = data.Contact?.Name || '';
            this.email = data.SuppliedEmail || '';
            this.applicationDetail = data.Description || '';
            this.businessRegion = data.Business_Region__c || '';
            this.businessUnit = data.Business_Region__c || '';
            this.country = data.Country__c || '';
            
            if (this.email && this.email.includes('@')) {
    const domain = this.email.split('@')[1];
    if (domain) {
        this.company = domain.replace('.com', '');
    }
} else if (data.Account?.Name) {
    this.company = data.Account.Name;
}
            const recordTypeName = data.RecordType?.Name;
        if (recordTypeName === 'Customer Service') {
            this.leadSource = 'Customer Service/Sales';
        } else if (recordTypeName === 'Tech Support') {
            this.leadSource = 'Technical Support';
        } else {
            this.leadSource = '';
        }

        } else if (error) {
            console.error('Error fetching case data:', error);
        }
    }

    connectedCallback() {
        getLeadPicklistValues()
            .then(result => {
                this.statusOptions = result.Status.map(val => ({ label: val, value: val }));
                this.leadSourceOptions = result.LeadSource.map(val => ({ label: val, value: val }));
                this.businessRegionOptions = result.Business_Region__c.map(val => ({ label: val, value: val }));
                this.countryOptions = result.Country__c.map(val => ({ label: val, value: val }));
                
            })
            .catch(error => {
                console.error('Picklist fetch error:', error);
            });
    }

    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
        if (field === 'businessRegion') {
            this.businessUnit = this[field];
        }
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleCreateLead() {
        this.isLoading = true;

        createLeadFromCase({
            caseId: this.recordId,
            name: this.name,
            email: this.email,
            company: this.company,
            status: this.status,
            leadSource: this.leadSource,
            businessRegion: this.businessRegion,
            businessUnit: this.businessUnit,
            applicationDetail: this.applicationDetail,
            country: this.country
        })
            .then(result => {
                const leadUrl = `/lightning/r/Lead/${result.Id}/view`;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Lead created. Click {0} to view.',
                        messageData: [{ url: leadUrl, label: result.Name }],
                        variant: 'success',
                        mode: 'sticky'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                console.error('Error creating lead:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body?.message || 'Unknown error',
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}