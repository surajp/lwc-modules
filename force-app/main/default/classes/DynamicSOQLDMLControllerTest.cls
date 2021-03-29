@isTest
public with sharing class DynamicSOQLDMLControllerTest {
  @isTest
  public static void testUpdate() {
    Account a = new Account(Name = 'Test Account');
    insert a;
    a.Phone = '432424';
    Account[] recordsToUpdate = new List<Account>{ a };
    DynamicSOQLDMLController.executeDml('update', JSON.serialize(recordsToUpdate), 'Account');
    a = [SELECT Phone FROM Account WHERE Id = :a.Id];
    System.assertEquals('432424', a.Phone);
  }

  @isTest
  public static void testInsert() {
    // we won't test fetching cmdt
    DynamicSOQLDMLController.getJSFromCmdt('Account');
    String acctString = '[{"attributes":{"type":"Account"},"Name":"Test Account"}]';
    DynamicSOQLDMLController.executeDml('insert', acctString, 'Account');
    System.assertEquals(1, [SELECT ID FROM Account WHERE Name = 'Test Account'].size());
  }

  @isTest
  public static void testUpsertInsert() {
    Account a = new Account(Name = 'Test Account');
    insert a;
    a.Phone = '432343';
    Account a1 = new Account(Name = 'Test Account 2');
    Account[] accountsToUpdate = new List<Account>{};
    accountsToUpdate.add(a);
    accountsToUpdate.add(a1);

    String acctString = JSON.serialize(accountsToUpdate);
    DynamicSOQLDMLController.executeDml('upsert', acctString, 'Account');
    System.assertEquals(2, [SELECT ID FROM Account].size());
    a = [SELECT Phone FROM Account WHERE Id = :a.Id];
    System.assertEquals('432343', a.Phone);
  }

  @isTest
  public static void testSoql() {
    Account a = new Account(Name = 'Test Account');
    insert a;
    Account[] acctsResult = DynamicSOQLDMLController.executeSoqlQuery('Select Name from Account');
    System.assertEquals(1, acctsResult.size());
    System.assertEquals('Test Account', acctsResult[0].Name);
  }
}
