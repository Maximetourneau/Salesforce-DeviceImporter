@isTest
private class DeviceImporterTest {
    @isTest static void testImportDevices() {
        // Set mock response
        Test.setMock(HttpCalloutMock.class, new DeviceCalloutMock());

        // Start test context
        Test.startTest();
        DeviceImporter.importDevices();
        Test.stopTest();

        // Verify results
        List<Device__c> results = [SELECT Name, Color__c, Capacity__c, Price__c FROM Device__c WHERE Name = 'Test Device'];
        System.assertEquals(1, results.size());
        System.assertEquals('Black', results[0].Color__c);
        System.assertEquals('46 GB', results[0].Capacity__c); // because it was 64 GB and must be updated
        System.assertEquals(2025.07, results[0].Price__c);
    }
}
