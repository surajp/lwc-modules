@isTest
public inherited sharing class ObjectInfoControllerTest {
  public class SObjectDescribeWrapper {
    public String name { get; set; }
  }

  public class FieldDescribeWrapper {
    public String name { get; set; }
    public String type { get; set; }
    public String label { get; set; }
  }

  @isTest
  private static void it_should_return_object_describe() {
    String acctDescribe = ObjectInfoController.getObjectInfo(new List<String>{ 'Account', 'Contact' });
    List<SObjectDescribeWrapper> acctDesc = (List<SObjectDescribeWrapper>) JSON.deserialize(
      acctDescribe,
      List<SObjectDescribeWrapper>.class
    );
    System.assertEquals('Account', acctDesc[0].name);
    System.assertEquals('Contact', acctDesc[1].name);
  }

  @isTest
  private static void it_should_return_field_describe() {
    String fieldDescribeStrings = ObjectInfoController.getFieldInfo(
      new List<String>{ 'Account.Name', 'Contact.LastName', 'Contact.Account.Owner.Phone' }
    );
    Map<String, FieldDescribeWrapper> fieldDesc = (Map<String, FieldDescribeWrapper>) JSON.deserialize(
      fieldDescribeStrings,
      Map<String, FieldDescribeWrapper>.class
    );
    System.assertEquals('Name', fieldDesc.get('Account.Name').name);
    System.assertEquals(Schema.DisplayType.STRING.name().toLowerCase(), fieldDesc.get('Account.Name').type);
    System.assertEquals('LastName', fieldDesc.get('Contact.LastName').name);
    System.assertEquals('Phone', fieldDesc.get('Contact.Account.Owner.Phone').name);
    System.assertEquals(
      Schema.DisplayType.PHONE.name().toLowerCase(),
      fieldDesc.get('Contact.Account.Owner.Phone').type
    );
  }
}
