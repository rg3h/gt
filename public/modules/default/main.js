/**
 * @fileoverview main.js entry point into javascript
 */
import {formatDate, updateOnTheMinute} from '../date/date.js';
import {getVersion} from '../util/util.js';

window.addEventListener('load', main);
async function main() {
  return init();
} // main

async function init() {
  updateTitleVersionEle();
  updateOnTheMinute(updateTitleDateEle);
  return 1;
}

function updateTitleVersionEle() {
  let versionEle = document.getElementsByClassName('titleVersion');
  versionEle.length>0 ? versionEle[0].innerText='version '+getVersion() : null;
}

function updateTitleDateEle() {
  let dateEle = document.getElementsByClassName('titleDate');
  dateEle.length > 0 ? dateEle[0].innerText = formatDate('DD MMMM YYYY') : null;
}
