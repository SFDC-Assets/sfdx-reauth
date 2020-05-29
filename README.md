# sfdx-reauth


Example for implementing an electronic signature (or Re-Auth) for approving records in Salesforce.

For detailed instructions on using the components in this project, see https://salesforce.quip.com/6TZyANHSaCan

This scenario came from a customer who is implementing a product lifecycle / quality management solution with AppExchange partner Propel (https://www.propelplm.com/product/quality-management). 

This customer creates products that have to comply with U.S. Food and Drug Administration (FDA) requirements that specify that electronic records must be approved with an ‘electronic signature’ by, at the very least, re-entering a password to re-authenticate the approver. See: https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfcfr/CFRSearch.cfm?CFRPart=11&showFR=1&subpartNode=21:1.0.1.1.8.3


## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `cci org browser dev` to open the org in your browser.