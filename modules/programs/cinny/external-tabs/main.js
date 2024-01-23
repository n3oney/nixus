function handleUpdated(id, changeInfo, _tab) {
  if (id !== 1 && changeInfo.url) {
    browser.tabs.remove(id);
    browser.runtime.sendNativeMessage("external_tabs", changeInfo.url);
  }
}

browser.tabs.onUpdated.addListener(handleUpdated);
