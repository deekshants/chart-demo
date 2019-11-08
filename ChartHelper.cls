public with sharing class ChartHelper {
    @AuraEnabled(cacheable=true)
    public static List<String> getAllFieldApis(String obj){
        Map<String, Schema.SObjectType> allObjectsMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult objInstance = allObjectsMap.get(obj).getDescribe();
        Map<String, Schema.SObjectField> allFields = objInstance.fields.getMap();
        Schema.DescribeFieldResult  fieldInstance;
        List<String> fieldListFinal = new List<String>();
        for (String fieldApiName : allFields.keySet()) {
            fieldInstance = allFields.get(fieldApiName).getDescribe();
            String str = String.valueOf(fieldInstance.getType()).toLowerCase();
            if (str  == 'boolean' || str == 'combobox' || str == 'currency' || str == 'double' || str == 'integer' || str == 'long' || str == 'multipicklist' || str == 'percent' || str == 'picklist') {
                fieldListFinal.add('{"label":"'+fieldInstance.getLabel()+'","value":"'+fieldInstance.getName()+'"}');
            }
        }
        System.debug(fieldListFinal);
        return fieldListFinal;
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordData(String obj, String field){
        
        Map<String, Schema.SObjectType> allObjectsMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult objInstance = allObjectsMap.get(obj).getDescribe();
        Schema.DescribeFieldResult fieldInstance = objInstance.fields.getMap().get(field).getDescribe();
        String fieldType = String.valueOf(fieldInstance.getType()).toLowerCase();
        BarChartData bcd = new BarChartData();
        bcd.fieldLabel = fieldInstance.getLabel();
        if (fieldType == 'currency' || fieldType == 'double' || fieldType == 'integer' || fieldType == 'long'|| fieldType == 'percent') {
            bcd.chartType = 'bar';
            String query = 'SELECT Id, '+field+' FROM '+obj+' WHERE '+field+' != null limit 10';
            for (sObject sobj: Database.query(query)) {
                bcd.data.add(Double.valueOf(sobj.get(field)));
                bcd.label.add(sobj.Id);
            }
        }
        else if(fieldType == 'combobox' || fieldType == 'multiPicklist' || fieldType == 'picklist'){
            bcd.chartType = 'pie';
            for(Schema.PicklistEntry p: fieldInstance.getPicklistValues()){
                String query = 'SELECT COUNT() FROM '+obj+' WHERE '+field+' = \''+p.getValue()+'\'';
	            bcd.data.add(Database.countQuery(query));
                bcd.label.add(p.getLabel());
            }
        }
        else if(fieldType == 'boolean'){
            bcd.chartType = 'pie';
            String trueQuery = 'SELECT COUNT() FROM '+obj+' WHERE '+field+' = TRUE';
            bcd.data.add(Database.countQuery(trueQuery));
            bcd.label.add('True');

            String falseQuery = 'SELECT COUNT() FROM '+obj+' WHERE '+field+' = FALSE';
            bcd.data.add(Database.countQuery(falseQuery));
            bcd.label.add('False');
        }
        
        System.debug(JSON.serialize(bcd));
        return JSON.serialize(bcd);
    }

    public class BarChartData{
        String chartType;
        String fieldLabel;
        List<Double> data;
        List<String> label;
        public BarChartData(){
            data = new List<Double>();
            label = new List<String>();
        }
    }
}


/*
Boolean );Combobox || Currency || Double || Integer || Long || MultiPicklist || Percent || Picklist
*/