@AbapCatalog.sqlViewName: 'ZSORDVEND'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.preserveKey: true
@UI:
{
headerInfo:
{
typeName: 'Vendor',
typeNamePlural: 'Vendors',
title: { type: #STANDARD, label: 'Vendor' }
}
}
@EndUserText.label: 'CDS view for Sales Order and Vendor'
define root view ZI_SORD_VENDOR_RAP
  as select from zsord_vendor_rap
{
      @UI.facet: [
      {
      id: 'Vendor',
      purpose: #STANDARD,
      type: #IDENTIFICATION_REFERENCE,
      label: 'Vendor Portal',
      position: 2 }
      ]
      @UI: {
      lineItem: [ { position: 5, importance: #HIGH, label: 'Sales Order' } ],
      selectionField: [ { position: 5 }] }
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Sales Order'
  key sord            as Sord,
      @UI: {
      lineItem: [ { position: 30, importance: #HIGH, label: 'Customer' } ],

      identification: [ { position: 30 } ],
      selectionField: [ { position: 30 } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Customer', element: 'CustomerID' } }]
      @Search.defaultSearchElement: true
      customerid      as Customerid,
      @UI: {
      lineItem: [ { position: 50, importance: #HIGH, label: 'Vendor' } ],
      identification: [ { position: 50 } ],
      selectionField: [ { position: 50 } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: '/DMO/I_Agency', element: 'AgencyID' } }]
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Vendor'
      vendorid        as Vendorid,
      @UI: {
      lineItem: [ { position: 70, importance: #HIGH, label: 'Delivery Country' } ],
      identification: [ { position: 70, label: 'Delivery Country' } ] }
      @Consumption.valueHelpDefinition: [{ entity : {name: 'I_Country', element: 'Country' } }]
      deliverycountry as Deliverycountry,
      @UI: {
      lineItem: [ { position: 90, importance: #HIGH, label: 'Description' } ],
      identification: [ { position: 90, label: 'Description' } ] }
      description     as Description,
      @UI: {
      lineItem: [ { position: 110, importance: #HIGH },
      { type: #FOR_ACTION, dataAction: 'set_status', label: 'Release Status' } ],
      identification: [ { position: 110, label: 'Release[O(Open)|R(Released)|X(Canceled)]' } ] }
      overallstatus   as Overallstatus,
      @UI: {
      lineItem: [ { position: 115, importance: #HIGH, label: 'Order Conf Date' } ],
      identification: [ { position: 115, label: 'Order Conf Date' } ]}
      orderconfdate   as Orderconfdate,
      @UI: {
      lineItem: [ { position: 125, importance: #HIGH, label: 'Delivery Date' } ],
      identification: [ { position: 125, label: 'DeliveryDate' } ] }
      deliverydate    as Deliverydate,

      @UI: {
      lineItem: [ { position: 130, importance: #HIGH, label: 'Remarks' } ],
      identification: [ { position: 130, label: 'Remarks' } ] }
      remarks         as Remarks,
      @UI.hidden: true
      @Semantics.user.createdBy: true
      createdby       as Createdby,
      @UI.hidden: true
      @Semantics.systemDateTime.createdAt: true
      createdat       as Createdat,
      @UI.hidden: true
      @Semantics.user.lastChangedBy: true
      lastchangedby   as Lastchangedby,
      @UI.hidden: true
      @Semantics.systemDateTime.lastChangedAt: true
      lastchangedat   as Lastchangedat
}
