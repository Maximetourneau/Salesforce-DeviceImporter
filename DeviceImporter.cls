public with sharing class DeviceImporter {

    public static void importDevices() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.restful-api.dev/objects');
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            List<Object> jsonList = (List<Object>) JSON.deserializeUntyped(response.getBody());

            List<Device__c> devicesToInsert = new List<Device__c>();

            // Get existing device names to prevent duplicates
            Set<String> existingNames = new Set<String>();
            for (Device__c d : [SELECT Name FROM Device__c]) {
                existingNames.add(d.Name);
            }

            for (Object o : jsonList) {
                Map<String, Object> deviceMap = (Map<String, Object>) o;

                String deviceName = (String) deviceMap.get('name');
                if (deviceName == null || existingNames.contains(deviceName)) {
                    continue; // Skip duplicates or null names
                }

                Map<String, Object> data = (Map<String, Object>) deviceMap.get('data');

                Device__c device = new Device__c();
                device.Name = deviceName;
                device.Color__c = (String) data.get('color');
                device.Capacity__c = (String) data.get('capacity');
                devicesToInsert.add(device);
            }

            if (!devicesToInsert.isEmpty()) {
                insert devicesToInsert;

                // Update all inserted records with 64 GB capacity to 46 GB
                List<Device__c> toUpdate = new List<Device__c>();
                for (Device__c d : devicesToInsert) {
                    if (d.Capacity__c == '64 GB') {
                        d.Capacity__c = '46 GB';
                        toUpdate.add(d);
                    }
                }
                if (!toUpdate.isEmpty()) {
                    update toUpdate;
                }
            }
        } else {
            System.debug('HTTP Error: ' + response.getStatusCode());
        }
    }
}