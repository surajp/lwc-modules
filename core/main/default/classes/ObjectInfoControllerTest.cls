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
    List<FieldDescribeWrapper> fieldDesc = (List<FieldDescribeWrapper>) JSON.deserialize(
      fieldDescribeStrings,
      List<FieldDescribeWrapper>.class
    );
    System.assertEquals('Name', fieldDesc[0].name);
    System.assertEquals(Schema.DisplayType.STRING.name().toLowerCase(), fieldDesc[0].type);
    System.assertEquals('LastName', fieldDesc[1].name);
    System.assertEquals('Phone', fieldDesc[2].name);
    System.assertEquals(Schema.DisplayType.PHONE.name().toLowerCase(), fieldDesc[2].type);
  }
}
