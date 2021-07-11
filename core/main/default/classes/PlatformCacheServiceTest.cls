@isTest
private class PlatformCacheServiceTest {
  private static final String TEST_KEY = 'testKey';
  private static final String TEST_VAL = 'testVal';
  @isTest
  private static void it_should_save_to_org_cache() {
    System.assert(
      PlatformCacheService.isPlatformCacheEnabled(),
      'Platform Cache should be enabled and a default partition set to deploy this class'
    );
    Test.startTest();
    PlatformCacheService.saveToOrgCache(TEST_KEY, TEST_VAL);
    Test.stopTest();
    system.assertEquals(
      PlatformCacheService.retrieveFromOrgCache(TEST_KEY).toString(),
      TEST_VAL,
      'Expected saved value to be retrieved from org cache'
    );
  }

  @isTest
  private static void it_should_remove_from_org_cache() {
    System.assert(
      PlatformCacheService.isPlatformCacheEnabled(),
      'Platform Cache should be enabled and a default partition set to deploy this class'
    );
    PlatformCacheService.saveToOrgCache(TEST_KEY, TEST_VAL);
    system.assertEquals(
      PlatformCacheService.retrieveFromOrgCache(TEST_KEY).toString(),
      TEST_VAL,
      'Expected saved value to be retrieved from org cache'
    );
    Test.startTest();
    PlatformCacheService.removeFromOrgCache(TEST_KEY);
    system.assertEquals(
      PlatformCacheService.retrieveFromOrgCache(TEST_KEY),
      null,
      'Expected saved value to have been removed from org cache'
    );
    Test.stopTest();
  }

  @isTest
  private static void it_should_save_to_session_cache() {
    System.assert(
      PlatformCacheService.isPlatformCacheEnabled(),
      'Platform Cache should be enabled and a default partition set to deploy this class'
    );
    Test.startTest();
    PlatformCacheService.saveToSessionCache(TEST_KEY, TEST_VAL);
    Test.stopTest();
    system.assertEquals(
      PlatformCacheService.retrieveFromSessionCache(TEST_KEY).toString(),
      TEST_VAL,
      'Expected saved value to be retrieved from org cache'
    );
  }

  @isTest
  private static void it_should_remove_from_session_cache() {
    System.assert(
      PlatformCacheService.isPlatformCacheEnabled(),
      'Platform Cache should be enabled and a default partition set to deploy this class'
    );
    PlatformCacheService.saveToSessionCache(TEST_KEY, TEST_VAL);
    system.assertEquals(
      PlatformCacheService.retrieveFromSessionCache(TEST_KEY).toString(),
      TEST_VAL,
      'Expected saved value to be retrieved from org cache'
    );
    Test.startTest();
    PlatformCacheService.removeFromOrgCache(TEST_KEY);
    system.assertEquals(
      PlatformCacheService.retrieveFromOrgCache(TEST_KEY),
      null,
      'Expected saved value to have been removed from org cache'
    );
    Test.stopTest();
  }
}
