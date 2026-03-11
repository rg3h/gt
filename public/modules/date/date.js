// @fileoverview module date.js
//  let locale = undefined; //  e.g. 'en-US'

export {
  getNextDay,                 // given opt date, incr, gets next date
  getPrevDay,                 // given opt date, incr, gets prev date
  getTomorrow,                // returns tomorrow as date
  getYesterday,               // returns yesterday as date

  getMonthLongNameList,       // returns array of long month names [January...]
  getMonthShortNameList,      // returns array of long month names [Jan...]
  getDayLongNameList,         // returns array of long day names [Sunday...]
  getDayShortNameList,        // returns array of short day names [Sun...]

  isValidDate,                // returns true if is a valid date type
  getDateAsInt,               // returns the number of seconds since epoch
  updateOnTheMinute,          // calls updateFn on the top of the minute
  updateDateOnTheMinute,      // updates the date every minute
  formatDay,                  // formats day 2-digit,numeric,long,short,narro
  formatDate,                 // takes a format string and replaces w/ the date
  formatMonth,                // formats mth 2-digit,numeric,long,short,narrow
  getMonthNumberFromName,     // given a month name, returns number (jan = 0)
  getNiceDate,                // 3 April 2022
  getNiceDateShort,           // 3 Apr 22
  getNiceTime,                // 2:45 PM
  getLocalDateFromUtc,        // convert a UTC date to the local date
};

/*export*/ const monthNameList = [
  'January','February','March','April','May','June','July',
  'August','September','October','November','December'
];

/*export*/ function getMonthLongNameList() {
  return monthNameList;
}

/*export*/ function getMonthShortNameList() {
  return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
}

/*export*/ function getDayLongNameList() {
  return ['Sunday', 'Monday', 'Tuesday', 'Wednesday',
          'Thursday', 'Friday', 'Saturday'];
}

/*export*/ function getDayShortNameList() {
  return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
}

/*private*/ function _getDayByIncrement(startDate=new Date(), increment=1) {
  const msInADay = 24 * 60 * 60 * 1000;
  return new Date(startDate.getTime() + (increment * msInADay));
}

/*export*/ function getNextDay(startDate=new Date(), increment=1) {
  return _getDayByIncrement(startDate, increment);
}

/*export*/ function getPrevDay(startDate=new Date(), increment=1) {
  return _getDayByIncrement(startDate, -1 * increment);
}

/*export*/ function getTomorrow() {
  return _getDayByIncrement(new Date(), 1);
}

/*export*/ function getYesterday() {
  return _getDayByIncrement(new Date(), -1);
}

/*export*/ function isValidDate(d) {
  return d instanceof Date && !isNaN(d);
}

/*export*/ function getDateAsInt(date=new Date()) {
  return date.getTime();
}

/*export*/ function updateOnTheMinute(updateFn) {
  updateFn();

  // compute the time until the next update
  let theDate = new Date();
  let secondsLeft = 60 - theDate.getSeconds(); // secs until minute mark
  let ms = secondsLeft < 0 ? 0 : secondsLeft * 1000;
  setTimeout(() => {updateOnTheMinute(updateFn)}, ms);
}

/*export*/ function getMonthNumberFromName(monthName) {
  return monthNameList.indexOf(monthName);
}

/*export*/ function updateDateOnTheMinute(dateContainerEle) {
  if (!dateContainerEle) { return }

  dateContainerEle.innerHTML = formatDate('DDDD, DD MMMM YYYY, HH:NN AMPM');

  // compute the time remaining until the next update
  let theDate = new Date();
  let secondsLeft = 60 - theDate.getSeconds(); // secs until the next minute
  //  let ms = secondsLeft < 0 ? 0 : secondsLeft * 1000;
  let ms = Math.max(0, secondsLeft * 1000);
  setTimeout(() => {updateDateOnTheMinute(dateContainerEle)}, ms);
}



// '2-digit' 'numeric' 'long' 'short' 'narrow'
/*export*/ function formatDay(date=new Date(),
                              dateStyle='numeric',
                              locale=undefined) {
  let param = dateStyle === 'numeric' ? {day:dateStyle} : {weekday:dateStyle};
  return date.toLocaleString(locale, param);
}

// '2-digit' 'numeric' 'long' 'short' 'narrow'
/*export*/ function formatMonth(date=new Date(),
                                dateStyle='long',
                                locale=undefined) {
  return date.toLocaleString(locale, {month:dateStyle});
}

/**
 * @param {string} format string like 'DD-MM-YYYY HH:NN:SS PM'
 *    2D   == day as two-digit number, 02
 *    DD   == day as number, 02
 *    DDD  == day as short, Sat
 *    DDDD == day as long, Saturday
 *    MM   == month as two-digit number, 03
 *    MMM  == month as short, Nov
 *    MMMM == month as long, November
 *    YYYY == year as long, 2022
 *    YY   == year as short, 22
 *    2H    == hour as two-digit number, 09
 *    HH   == hour as number, 9
 *    NN   == minutes, 04  (NOTE: NN not MM)
 *    SS   == seconds, 09
 *    MS   == as three digit milliseconds, 007
 *    AMPM == show AM/PM
 *    MIL  == show as military time (overrides AMPM)
 */
/*export*/ function formatDate(formatString='DDDD, DD MMMM YYYY, HH:NN AMPM',
                               date = new Date(),
                               locale=undefined) {
  date = date || new Date();

  if (formatString.indexOf('DDDD') > -1) {
    let DDDD = date.toLocaleString(locale, {weekday: 'long'});
    formatString = formatString.split('DDDD').join(DDDD);
  }

  if (formatString.indexOf('DDD') > -1) {
    let DDD = date.toLocaleString(locale, {weekday: 'short'});
    formatString = formatString.split('DDD').join(DDD);
  }

  if (formatString.indexOf('DD') > -1) {
    let DD = date.toLocaleString(locale, {day: 'numeric'});
    formatString = formatString.split('DD').join(DD);
  }

  if (formatString.indexOf('2D') > -1) {
    let D2 = date.toLocaleString(locale, {day: '2-digit'});
    formatString = formatString.split('2D').join(D2);
  }

  if (formatString.indexOf('MMMM') > -1) {
    let MMMM = date.toLocaleString(locale, {month: 'long'});
    formatString = formatString.split('MMMM').join(MMMM);
  }

  if (formatString.indexOf('MMM') > -1) {
    let MMM = date.toLocaleString(locale, {month: 'short'});
    formatString = formatString.split('MMM').join(MMM);
  }

  if (formatString.indexOf('MM') > -1) {
    let MM = date.toLocaleString(locale, {month: 'numeric'});
    formatString = formatString.split('MM').join(MM);
  }

  if (formatString.indexOf('2M') > -1) {
    let M2 = date.toLocaleString(locale, {month: '2-digit'});
    formatString = formatString.split('2M').join(M2);
  }

  if (formatString.indexOf('YYYY') > -1) {
    let YYYY = date.toLocaleString(locale, {year: 'numeric'});
    formatString = formatString.split('YYYY').join(YYYY);
  }

  if (formatString.indexOf('YY') > -1) {
    let YY = date.toLocaleString(locale, {year: '2-digit'});
    formatString = formatString.split('YY').join(YY);
  }

  if (formatString.indexOf('HH') > -1) {
    let args = {};
    args.hour12 = formatString.indexOf('MIL') < 0; // no MIL means true
    args.hour = 'numeric';
    let HH = date.toLocaleString(locale, args).split(' ')[0];
    formatString = formatString.split('HH').join(HH);
  }

  if (formatString.indexOf('2H') > -1) {
    let args = {};
    args.hour12 = formatString.indexOf('MIL') < 0; // no MIL means true
    args.hour = '2-digit';
    let H2 = date.toLocaleString(locale, args).split(' ')[0];
    formatString = formatString.split('2H').join(H2);
  }

  if (formatString.indexOf('NN') > -1) {
    let NN = date.toLocaleString(locale, {minute: '2-digit'});
    NN = NN.length < 2 ? '0' + NN : NN;
    formatString = formatString.split('NN').join(NN);
  }

  if (formatString.indexOf('SS') > -1) {
    let SS = date.toLocaleString(locale, {second: '2-digit'});
    SS = SS.length < 2 ? '0' + SS : SS;
    formatString = formatString.split('SS').join(SS);
  }

  if (formatString.indexOf('MS') > -1) {
    let MS = date.toLocaleString(locale, {fractionalSecondDigits: 3});
    formatString = formatString.split('MS').join(MS);
  }

  if (formatString.indexOf('AMPM') > -1) {
    let args = {};
    args.hour12 = true;
    args.hour = 'numeric';
    let AMPM = date.toLocaleString(locale, args).split(' ')[1];
    formatString = formatString.split('AMPM').join(AMPM);
  }

  return formatString;
}

/*export*/ function getNiceDate(date=new Date(), showDay=false) {
  let formatString = showDay ? 'DDDD, DD MMMM YYYY' : 'DD MMMM YYYY';
  return formatDate(formatString, date);
}

/*export*/ function getNiceDateShort(date=new Date()) {
  return formatDate('DD MMM YY', date);
}

/*export*/ function getNiceTime(date=new Date()) {
  return formatDate('HH:NN:SS AMPM', date);
}

/*export*/ function getLocalDateFromUtc(utcDate, locale=undefined) {
  return utcDate.toLocaleString(locale);
}
