/*****************************************************************************
 *  FILE:  anytime.prototype.js - The Any+Time(TM) JavaScript Library (source)
 *
 *  VERSION: 2.991
 *
 *  Copyright 2008-2010 Andrew M. Andrews III (www.AMA3.com). Some Rights 
 *  Reserved. This work licensed under the Creative Commons Attribution-
 *  Noncommercial-Share Alike 3.0 Unported License except in jurisdicitons
 *  for which the license has been ported by Creative Commons International,
 *  where the work is licensed under the applicable ported license instead.
 *  For a copy of the unported license, visit
 *  http://creativecommons.org/licenses/by-nc-sa/3.0/
 *  or send a letter to Creative Commons, 171 Second Street, Suite 300,
 *  San Francisco, California, 94105, USA.  For ported versions of the
 *  license, visit http://creativecommons.org/international/
 *
 *  Alternative licensing arrangements may be made by contacting the
 *  author at http://www.AMA3.com/contact/
 *
 *  The Any+Time JavaScript Library provides two classes for manipulating
 *  dates and times using the ECMAScript language:
 *
 *    ATConverter
 *      converts a Date to/from a String, allowing a wide range of formats
 *      closely matching those provided by the MySQL DATE_FORMAT() function,
 *      with some noteworthy enhancements.
 *
 *    ATWidget
 *      An Ajax-enabled calendar widget for a text field that selects date/
 *      time values with fewer mouse movements than most similar widgets.
 *      Any format supported by ATConverter can be used for the text field.
 *      If JavaScript is disabled, the text field remains editable without
 *      any of the ATWidget features.
 *
 *  IMPORTANT NOTICE:  This code depends upon the Prototype Library
 *  (www.prototypejs.org), currently version 1.6.1.
 *
 *  The ATWidget code and styles in anytime.css have been tested (but not
 *  extensively) on Windows Vista in Internet Explorer 8.0, Firefox 3.0, Opera
 *  9.64 and Safari 4.0.  Minor variations in IE7- are to be expected, due
 *  to its broken box model. Please report any other problems to the author
 *  (URL above).
 *
 *  Any+Time is a trademark of Andrew M. Andrews III.
 ****************************************************************************/

//=============================================================================
//  ATConverter
//
//  This object converts between Date objects and Strings.
//
//  To use an ATConverter, simply create an instance for a format string,
//  and then (repeatedly) invoke the format() and/or parse() methods to
//  perform the conversions.  For example:
//
//    var converter = new Converter({format:'%Y-%m-%d'})
//    var datetime = converter.parse('1967-07-30') // July 30, 1967 @ 00:00
//    alert( converter.format(datetime) ); // outputs: 1967-07-30
//=============================================================================

var ATConverter = Class.create(
{
  fmt: '%Y-%m-%d %T',
  flen: 0,
  dAbbr: $A(['Sun','Mon','Tue','Wed','Thu','Fri','Sat']),
  dNames: $A(['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']),
  dNums: $H(),
  eAbbr: $A(['BCE','CE']),
  mAbbr: $A([ 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec' ]),
  mNames: $A([ 'January','February','March','April','May','June','July','August','September','October','November','December' ]),
  mNums: $H(),
  shortDay: 6,
  longDay: 9,
  shortMon: 3,
  longMon: 9,

  //-------------------------------------------------------------------------
  //  ATConverter#initialize()
  //
  //  The constructor takes one parameter:
  //
  //  options - an object (associative array) of optional parameters that
  //    override default behaviors.  The supported options are:
  //
  //    dayAbbreviations - an array of seven strings, indexed 0-6, to be used
  //      as ABBREVIATED day names.  If not specified, the following are used:
  //      ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
  //      Note that if the firstDOW option is passed to ATWidget (see
  //      ATWidget#initialize()), this array should nonetheless begin with
  //      the desired abbreviation for Sunday.
  //
  //    dayNames - an array of seven strings, indexed 0-6, to be used as
  //      day names.  If not specified, the following are used: ['Sunday',
  //        'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']
  //      Note that if the firstDOW option is passed to ATWidget (see
  //      ATWidget#initialize()), this array should nonetheless begin with
  //      the desired name for Sunday.
  //
  //    eraAbbreviations - an array of two strings, indexed 0-1, to be used
  //      as ABBREVIATED era names.  Item #0 is the abbreviation for "Before
  //      Common Era" (years before 0001, sometimes represented as negative
  //      years or "B.C"), while item #1 is the abbreviation for "Common Era"
  //      (years from 0001 to present, usually represented as unsigned years
  //      or years "A.D.").  If not specified, the following are used:
  //      ['BCE','CE']
  //
  //    format - a string specifying the pattern of strings involved in the
  //      conversion.  The parse() method can take a string in this format and
  //      convert it to a Date, and the format() method can take a Date object
  //      and convert it to a string matching the format.
  //
  //      Fields in the format string must match those for the DATE_FORMAT()
  //      function in MySQL, as defined here:
  //      http://tinyurl.com/bwd45#function_date-format
  //
  //      IMPORTANT:  Some MySQL specifiers are not supported (especially
  //      those involving day-of-the-year, week-of-the-year) or approximated.
  //      See the code for exact behavior.
  //
  //      In addition to the MySQL format specifiers, the following custom
  //      specifiers are also supported:
  //
  //        %B - If the year is before 0001, then the "Before Common Era"
  //          abbreviation (usually BCE or the obsolete BC) will go here.
  //
  //        %C - If the year is 0001 or later, then the "Common Era"
  //          abbreviation (usually CE or the obsolete AD) will go here.
  //
  //        %E - If the year is before 0001, then the "Before Common Era"
  //          abbreviation (usually BCE or the obsolete BC) will go here.
  //          Otherwise, the "Common Era" abbreviation (usually CE or the
  //          obsolete AD) will go here.
  //
  //        %Z - The current four-digit year, without any sign.  This is
  //          commonly used with years that might be before (or after) 0001,
  //          when the %E (or %B and %C) specifier is used instead of a sign.
  //          For example, 45 BCE is represented "0045".  By comparison, in
  //          the "%Y" format, 45 BCE is represented "-0045".
  //
  //        %z - The current year, without any sign, using only the necessary
  //          number of digits.  This if the year is commonly used with years
  //          that might be before (or after) 0001, when the %E (or %B and %C)
  //          specifier is used instead of a sign.  For example, the year
  //          45 BCE is represented as "45", and the year 312 CE as "312".
  //
  //    monthAbbreviations - an array of twelve strings, indexed 0-6, to be
  //      used as ABBREVIATED month names.  If not specified, the following
  //      are used: ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep',
  //        'Oct','Nov','Dec']
  //
  //    monthNames - an array of twelve strings, indexed 0-6, to be used as
  //      month names.  If not specified, the following are used:
  //      ['January','February','March','April','May','June','July',
  //        'August','September','October','November','Decembe']
  //
  //-------------------------------------------------------------------------

  initialize: function( options )
  {
    var i;

    if ( ! options )
      options = {};

    if ( options['format'] )
      this.fmt = options['format'];

    this.flen = this.fmt.length;

    if ( options['dayAbbreviations'] )
      this.dAbbr = $A( options['dayAbbreviations'] );

    if ( options['dayNames'] )
    {
      this.dNames = $A( options['dayNames'] );
      this.longDay = 1;
      this.shortDay = 1000;
      for ( i = 0 ; i < 7 ; i++ )
      {
        var len = this.dNames[i].length;
        if ( len > this.longDay )
          this.longDay = len;
        if ( len < this.shortDay )
          this.shortDay = len;
      }
    }

    if ( options['eraAbbreviations'] )
      this.eAbbr = $A( options['eraAbbreviations'] );

    if ( options['monthAbbreviations'] )
      this.mAbbr = $A( options['monthAbbreviations'] );

    if ( options['monthNames'] )
    {
      this.mNames = $A( options['monthNames'] );
      this.longMon = 1;
      this.shortMon = 1000;
      for ( i = 0 ; i < 12 ; i++ )
      {
        var len = this.mNames[i].length;
        if ( len > this.longMon )
          this.longMon = len;
        if ( len < this.shortMon )
          this.shortMon = len;
      }
    }

    for ( i = 0 ; i < 12 ; i++ )
    {
      this.mNums.set(this.mAbbr[i],i);
      this.mNums.set(this.mNames[i],i);
    }

    for ( i = 0 ; i < 7 ; i++ )
    {
      this.dNums.set(this.dAbbr[i],i);
      this.dNums.set(this.dNames[i],i);
    }

    return;
  }, // ATConverter#constructor()

  //-------------------------------------------------------------------------
  //  ATConverter#dAt() is used internally to determine whether the character
  //  at a certain position in a string is a digit.
  //-------------------------------------------------------------------------

  dAt: function( str, pos )
  {
    return ( (str.charCodeAt(pos)>='0'.charCodeAt(0)) &&
            (str.charCodeAt(pos)<='9'.charCodeAt(0)) );
  },

  //-------------------------------------------------------------------------
  //  ATConverter#format() creates a String containing the value of a
  //  specified Date object, using the format string passed to the
  //  ATConverter constructor.  The parameter is:
  //
  //    date - the Date object to be converted
  //
  //  The created String is returned.
  //-------------------------------------------------------------------------

  format: function( date )
  {
    var t;
    var str = '';
    for ( var f = 0 ; f < this.flen ; f++ )
    {
      if ( this.fmt.charAt(f) != '%' )
        str += this.fmt.charAt(f);
      else
      {
        switch ( this.fmt.charAt(f+1) )
        {
          case 'a': // Abbreviated weekday name (Sun..Sat)
            str += this.dAbbr[ date.getDay() ];
            break;
          case 'B': // BCE string (eAbbr[0], usually BCE or BC, only if appropriate) (NON-MYSQL)
            if ( date.getFullYear() < 0 )
              str += this.eAbbr[0];
            break;
          case 'b': // Abbreviated month name (Jan..Dec)
            str += this.mAbbr[ date.getMonth() ];
            break;
          case 'C': // CE string (eAbbr[1], usually CE or AD, only if appropriate) (NON-MYSQL)
            if ( date.getFullYear() > 0 )
              str += this.eAbbr[1];
            break;
          case 'c': // Month, numeric (0..12)
            str += date.getMonth()+1;
            break;
          case 'd': // Day of the month, numeric (00..31)
            t = date.getDate();
            if ( t < 10 ) str += '0';
            str += String(t);
            break;
          case 'D': // Day of the month with English suffix (0th, 1st,...)
            t = String(date.getDate());
            str += t;
            if ( ( t.length == 2 ) && ( t.charAt(0) == '1' ) )
              str += 'th';
            else
            {
              switch ( t.charAt( t.length-1 ) )
              {
                case '1': str += 'st'; break;
                case '2': str += 'nd'; break;
                case '3': str += 'rd'; break;
                default: str += 'th'; break;
              }
            }
            break;
          case 'E': // era string (from eAbbr[], BCE, CE, BC or AD) (NON-MYSQL)
            str += this.eAbbr[ (date.getFullYear()<0) ? 0 : 1 ];
            break;
          case 'e': // Day of the month, numeric (0..31)
            str += date.getDate();
            break;
          case 'H': // Hour (00..23)
            t = date.getHours();
            if ( t < 10 ) str += '0';
            str += String(t);
            break;
          case 'h': // Hour (01..12)
          case 'I': // Hour (01..12)
            t = date.getHours() % 12;
            if ( t == 0 )
              str += '12';
            else
            {
              if ( t < 10 ) str += '0';
              str += String(t);
            }
            break;
          case 'i': // Minutes, numeric (00..59)
            t = date.getMinutes();
            if ( t < 10 ) str += '0';
            str += String(t);
            break;
          case 'k': // Hour (0..23)
            str += date.getHours();
            break;
          case 'l': // Hour (1..12)
            t = date.getHours() % 12;
            if ( t == 0 )
              str += '12';
            else
              str += String(t);
            break;
          case 'M': // Month name (January..December)
            str += this.mNames[ date.getMonth() ];
            break;
          case 'm': // Month, numeric (00..12)
            t = date.getMonth() + 1;
            if ( t < 10 ) str += '0';
            str += String(t);
            break;
          case 'p': // AM or PM
            str += ( ( date.getHours() < 12 ) ? 'AM' : 'PM' );
            break;
          case 'r': // Time, 12-hour (hh:mm:ss followed by AM or PM)
            t = date.getHours() % 12;
            if ( t == 0 )
              str += '12:';
            else
            {
              if ( t < 10 ) str += '0';
              str += String(t) + ':';
            }
            t = date.getMinutes();
            if ( t < 10 ) str += '0';
            str += String(t) + ':';
            t = date.getSeconds();
            if ( t < 10 ) str += '0';
            str += String(t);
            str += ( ( date.getHours() < 12 ) ? 'AM' : 'PM' );
            break;
          case 'S': // Seconds (00..59)
          case 's': // Seconds (00..59)
            t = date.getSeconds();
            if ( t < 10 ) str += '0';
            str += String(t);
            break;
          case 'T': // Time, 24-hour (hh:mm:ss)
            t = date.getHours();
            if ( t < 10 ) str += '0';
            str += String(t) + ':';
            t = date.getMinutes();
            if ( t < 10 ) str += '0';
            str += String(t) + ':';
            t = date.getSeconds();
            if ( t < 10 ) str += '0';
            str += String(t);
            break;
          case 'W': // Weekday name (Sunday..Saturday)
            str += this.dNames[ date.getDay() ];
            break;
          case 'w': // Day of the week (0=Sunday..6=Saturday)
            str += date.getDay();
            break;
          case 'Y': // Year, numeric, four digits (negative if before 0001)
            str += this.pad(date.getFullYear(),4);
            break;
          case 'y': // Year, numeric (two digits, negative if before 0001)
            t = date.getFullYear() % 100;
            str += this.pad(t,2);
            break;
          case 'Z': // Year, numeric, four digits, unsigned (NON-MYSQL)
            str += this.pad(Math.abs(date.getFullYear()),4);
            break;
          case 'z': // Year, numeric, variable length, unsigned (NON-MYSQL)
            str += Math.abs(date.getFullYear());
            break;
          case '%': // A literal '%' character
            str += '%';
            break;
          case 'f': // Microseconds (000000..999999)
          case 'j': // Day of year (001..366)
          case 'U': // Week (00..53), where Sunday is the first day of the week
          case 'u': // Week (00..53), where Monday is the first day of the week
          case 'V': // Week (01..53), where Sunday is the first day of the week; used with %X
          case 'v': // Week (01..53), where Monday is the first day of the week; used with %x
          case 'X': // Year for the week where Sunday is the first day of the week, numeric, four digits; used with %V
          case 'x': // Year for the week, where Monday is the first day of the week, numeric, four digits; used with %v
            throw '%'+this.fmt.charAt(f)+' not implemented by ATConverter';
          default: // for any character not listed above
            str += this.fmt.substr(f,2);
        } // switch ( this.fmt.charAt(f+1) )
        f++;
      } // else
    } // for ( var f = 0 ; f < this.flen ; f++ )
    return str;
  }, // ATConverter#format()

  //-------------------------------------------------------------------------
  //  ATConverter#pad() is called internally (and by ATWidget) to pad a value
  //  with a specified number of zeroes.
  //-------------------------------------------------------------------------

  pad: function( val, len )
  {
    var str = String(Math.abs(val));
    while ( str.length < len )
      str = '0'+str;
    if ( val < 0 )
      str = '-'+str;
    return str;
  },

  //-------------------------------------------------------------------------
  //  ATConverter#parse() creates a Date object initialized from a
  //  specified String, using the format string passed to the ATConverter
  //  constructor.  The parameter is:
  //
  //    str - the String object to be converted
  //
  //  The created Date is returned.
  //-------------------------------------------------------------------------

  parse: function( str )
  {
    var era = 1;
    var time = new Date();
    var slen = str.length;
    var s = 0;
    var i, matched, sub, sublen;
    for ( var f = 0 ; f < this.flen ; f++ )
    {
      if ( this.fmt.charAt(f) == '%' )
      {
        switch ( this.fmt.charAt(f+1) )
        {
          case 'a': // Abbreviated weekday name (Sun..Sat)
            matched = false;
            for ( sublen = 0 ; s + sublen < slen ; sublen++ )
            {
              sub = str.substr(s,sublen);
              for ( i = 0 ; i < 12 ; i++ )
                if ( this.dAbbr[i] == sub )
                {
                  matched = true;
                  s += sublen;
                  break;
                }
              if ( matched )
                break;
            } // for ( sublen ... )
            if ( ! matched )
              throw new Exception('unknown weekday: '+str.substr(s));
            break;
          case 'B': // BCE string (eAbbr[0]), only if needed. (NON-MYSQL)
            sublen = this.eAbbr[0].length;
            if ( ( s + sublen <= slen ) && ( str.substr(s,sublen) == this.eAbbr[0] ) )
            {
              era = (-1);
              s += sublen;
            }
            break;
          case 'b': // Abbreviated month name (Jan..Dec)
            matched = false;
            for ( sublen = 0 ; s + sublen < slen ; sublen++ )
            {
              sub = str.substr(s,sublen);
              for ( i = 0 ; i < 12 ; i++ )
                if ( this.mAbbr[i] == sub )
                {
                  time.setMonth( i );
                  matched = true;
                  s += sublen;
                  break;
                }
              if ( matched )
                break;
            } // for ( sublen ... )
            if ( ! matched )
              throw new Exception('unknown month: '+str.substr(s));
            break;
          case 'C': // CE string (eAbbr[1]), only if needed. (NON-MYSQL)
            sublen = this.eAbbr[1].length;
            if ( ( s + sublen <= slen ) && ( str.substr(s,sublen) == this.eAbbr[1] ) )
              s += sublen; // note: CE is the default era
            break;
          case 'c': // Month, numeric (0..12)
            if ( ( s+1 < slen ) && this.dAt(str,s+1) )
            {
              time.setMonth( (Number(str.substr(s,2))-1)%12 );
              s += 2;
            }
            else
            {
              time.setMonth( (Number(str.substr(s,1))-1)%12 );
              s++;
            }
            break;
          case 'D': // Day of the month with English suffix (0th,1st,...)
            if ( ( s+1 < slen ) && this.dAt(str,s+1) )
            {
              time.setDate( Number(str.substr(s,2)) );
              s += 4;
            }
            else
            {
              time.setDate( Number(str.substr(s,1)) );
              s += 3;
            }
            break;
          case 'd': // Day of the month, numeric (00..31)
            time.setDate( Number(str.substr(s,2)) );
            s += 2;
            break;
          case 'E': // era string (from eAbbr[]) (NON-MYSQL)
            sublen = this.eAbbr[0].length;
            if ( ( s + sublen <= slen ) && ( str.substr(s,sublen) == this.eAbbr[0] ) )
            {
              era = (-1);
              s += sublen;
            }
            else if ( ( s + ( sublen = this.eAbbr[1].length ) <= slen ) && ( str.substr(s,sublen) == this.eAbbr[1] ) )
              s += sublen; // note: CE is the default era
            else
              throw new Exception('unknown era: '+str.substr(s));
            break;
          case 'e': // Day of the month, numeric (0..31)
            if ( ( s+1 < slen ) && this.dAt(str,s+1) )
            {
              time.setDate( Number(str.substr(s,2)) );
              s += 2;
            }
            else
            {
              time.setDate( Number(str.substr(s,1)) );
              s++;
            }
            break;
          case 'f': // Microseconds (000000..999999)
            s += 6; // SKIPPED!
            break;
          case 'H': // Hour (00..23)
            time.setHours( Number(str.substr(s,2)) );
            s += 2;
            break;
          case 'h': // Hour (01..12)
          case 'I': // Hour (01..12)
            time.setHours( Number(str.substr(s,2)) );
            s += 2;
            break;
          case 'i': // Minutes, numeric (00..59)
            time.setMinutes( Number(str.substr(s,2)) );
            s += 2;
            break;
          case 'k': // Hour (0..23)
            if ( ( s+1 < slen ) && this.dAt(str,s+1) )
            {
              time.setHours( Number(str.substr(s,2)) );
              s += 2;
            }
            else
            {
              time.setHours( Number(str.substr(s,1)) );
              s++;
            }
            break;
          case 'l': // Hour (1..12)
            if ( ( s+1 < slen ) && this.dAt(str,s+1) )
            {
              time.setHours( Number(str.substr(s,2)) );
              s += 2;
            }
            else
            {
              time.setHours( Number(str.substr(s,1)) );
              s++;
            }
            break;
          case 'M': // Month name (January..December)
            matched = false;
            for (sublen=this.shortMon ; s + sublen <= slen ; sublen++ )
            {
              if ( sublen > this.longMon )
                break;
              sub = str.substr(s,sublen);
              for ( i = 0 ; i < 12 ; i++ )
              {
                if ( this.mNames[i] == sub )
                {
                  time.setMonth( i );
                  matched = true;
                  s += sublen;
                  break;
                }
              }
              if ( matched )
                break;
            }
            break;
          case 'm': // Month, numeric (00..12)
            time.setMonth( (Number(str.substr(s,2))-1)%12 );
            s += 2;
            break;
          case 'p': // AM or PM
            if ( str.charAt(s) == 'P' )
            {
              if ( time.getHours() == 12 )
                time.setHours(0);
              else
                time.setHours( time.getHours() + 12 );
            }
            s += 2;
            break;
          case 'r': // Time, 12-hour (hh:mm:ss followed by AM or PM)
            time.setHours(Number(str.substr(s,2)));
            time.setMinutes(Number(str.substr(s+3,2)));
            time.setSeconds(Number(str.substr(s+6,2)));
            if ( str.substr(s+8,1) == 'P' )
            {
              if ( time.getHours() == 12 )
                time.setHours(0);
              else
                time.setHours( time.getHours() + 12 );
            }
            s += 10;
            break;
          case 'S': // Seconds (00..59)
          case 's': // Seconds (00..59)
            time.setSeconds(Number(str.substr(s,2)));
            s += 2;
            break;
          case 'T': // Time, 24-hour (hh:mm:ss)
            time.setHours(Number(str.substr(s,2)));
            time.setMinutes(Number(str.substr(s+3,2)));
            time.setSeconds(Number(str.substr(s+6,2)));
            s += 8;
            break;
          case 'W': // Weekday name (Sunday..Saturday)
            matched = false;
            for (sublen=this.shortDay ; s + sublen <= slen ; sublen++ )
            {
              if ( sublen > this.longDay )
                break;
              sub = str.substr(s,sublen);
              for ( i = 0 ; i < 7 ; i++ )
              {
                if ( this.dNames[i] == sub )
                {
                  matched = true;
                  s += sublen;
                  break;
                }
              }
              if ( matched )
                break;
            }
            break;
          case 'Y': // Year, numeric, four digits, negative if before 0001
            i = 4;
            if ( str.substr(s,1) == '-' )
              i++;
            time.setFullYear(Number(str.substr(s,i)));
            s += i;
            break;
          case 'y': // Year, numeric (two digits), negative if before 0001
            i = 2;
            if ( str.substr(s,1) == '-' )
              i++;
            time.setYear(Number(str.substr(s,i)));
            s += i;
            break;
          case 'Z': // Year, numeric, four digits, unsigned (NON-MYSQL)
            time.setFullYear(Number(str.substr(s,4)));
            s += 4;
            break;
          case 'z': // Year, numeric, variable length, unsigned (NON-MYSQL)
            i = 0;
            while ( ( s < slen ) && this.dAt(str,s) )
              i = ( i * 10 ) + Number(str.charAt(s++));
            time.setFullYear(i);
            break;
          case 'j': // Day of year (001..366)
          case 'U': // Week (00..53), where Sunday is the first day of the week
          case 'u': // Week (00..53), where Monday is the first day of the week
          case 'V': // Week (01..53), where Sunday is the first day of the week; used with %X
          case 'v': // Week (01..53), where Monday is the first day of the week; used with %x
          case 'w': // Day of the week (0=Sunday..6=Saturday)
          case 'X': // Year for the week where Sunday is the first day of the week, numeric, four digits; used with %V
          case 'x': // Year for the week, where Monday is the first day of the week, numeric, four digits; used with %v
            throw '%'+this.fmt.charAt(f+1)+' not implemented by ATConverter';
          case '%': // A literal '%' character
          default: // for any character not listed above
            s++;
            break;
        }
        f++;
      } // if ( this.fmt.charAt(f) == '%' )
      else if ( this.fmt.charAt(f) != str.charAt(s) )
        throw str + ' is not in "' + this.fmt + '" format';
      else
        s++;
    } // for ( var f ... )
    if ( era < 0 )
      time.setFullYear( 0 - time.getFullYear() );
    return time;
  } // ATConverter#parse()

}); // ATConverter


//=============================================================================
//  ATWidget
//
//  This object creates a date/time entry widget attached to a specific
//  text field.  Instead of entering a date and/or time into the text
//  field, the user selects legal combinations using the widget, and
//  the field is automatically populated.  The widget can be incorporated
//  into the page "inline", or used as a "popup" that appears when the
//  text field is clicked and disappears when the widget is dismissed.
//  Ajax can be used to send the selected value to a server to approve
//  or veto it.
//
//  To use an ATWidget widget, simply include the necessary files in an
//  HTML page and create an instance for each date/time textfield.  The
//  following creates a popup widget for field "foo" using the default
//  format, and a second date-only (no time) inline (always-visible)
//  Ajax-enabled widget for field "bar":
//
//    <link rel="stylesheet" type="text/css" href="anytime.css" />
//    <script type="text/javascript" src="prototype.js"></script>
//    <script type="text/javascript" src="anytime.js"></script>
//    <input type="text" id="foo" tabindex="100" value="1967-07-30 23:45" />
//    <input type="text" id="bar" tabindex="260" value="01/06/90" />
//    <script type="text/javascript">
//      new ATWidget( "foo" );
//      new ATWidget( "bar", { placement:"inline",
//                             format: "%m/%d/%y",
//                             url: "/some/server/page/" } );
//    </script>
//
//  See the initialize() function for arguments to pass to the constructor.
//
//  The appearance of the widget can be extensively modified using CSS styles.
//  A default appearance can be achieved by the "quickcal.css" stylesheet that
//  accompanies this script.  The default style looks better in browsers other
//  than Internet Explorer (before IE8) because older versions of IE do not
//  properly implement the CSS box model standard; however, it is passable in
//  Internet Explorer as well.
//=============================================================================

var ATWidgetIframe = null;
var ATWidgetInstances = new Hash();

var ATWidget = Class.create( ATConverter,
{
  ajaxOpts: {},   // options for AJAX requests
  cloak: null,    // cloak div
  div: null,      // widget div
  inp: null,      // input text field
  id: null,       // widget ID (Atw_*)
  lX: 'X',        // label for dismiss button
  pop: true,      // widget is a popup?
  askEra: false,  // prompt the user for the era in yDiv?
  fDOW: 0,     // index to use as first day-of-week
  earliest: null, // earliest selectable date/time
  latest: null,   // latest selectable date/time
  lastAjax: null, // last value submitted using AJAX
  time: null,     // current date/time
  url: null,      // URL to submit value using AJAX
  yLab: null,     // year label
  yDiv: null,     // year selector popup
  yPast: null,    // years-past button
  yAhead: null,   // years-ahead button
  yPrior: null,   // prior-year button
  yCur: null,     // current-year button
  yNext: null,    // next-year button
  y0XXX: null,    // millenium-digit-zero button (for focus)

  //--------------------------------------------------------------------------
  //  ATWidget#initialize()
  //
  //  This ATWidget constructor takes two parameters:
  //
  //  id - the "id" attribute of the textfield to associate with the
  //    ATWidget object.  The ATWidget will attach itself to the textfield
  //    and manage its value.   For best results, the textfield must have a
  //    "tabindex" attribute set, and the tabindex of the next control must
  //    be one-hundred (160) greater than the tabindex of the textfield, to
  //    allow the inserted controls to appear in the correct tab order.
  //
  //  options - an object (associative array) of optional parameters that
  //    override default behaviors.  The supported options are:
  //
  //    ajaxOptions - options to pass to Prototype's Ajax.Request
  //      constructor if option "url" is also provided (see "url").
  //
  //    askEra - if true, buttons to select the era are shown on the year
  //        selector popup, even if format specifier does not include the
  //        era.  If false, buttons to select the era are NOT shown, even
  //        if the format specifier includes ther era.  Normally, era buttons
  //        are only shown if the format string specifies the era.
  //
  //    askSecond - if false, buttons for number-of-seconds are not shown
  //        even if the format includes seconds.  Normally, the buttons
  //        are shown if the format string includes seconds.
  //
  //    earliest - String or Date object representing the earliest date/time
  //        that a user can select.  For best results if the field is only
  //        used to specify a date, be sure to set the time to 00:00:00.
  //        If a String is used, it will be parsed according to the widget's
  //        format (see ATConverter#format).
  //
  //    firstDOW - a value from 0 (Sunday) to 6 (Saturday) stating which
  //      day should appear at the beginning of the week.  The default is 0
  //      (Sunday).  The most common substitution is 1 (Monday).  Note that
  //      if custom arrays are specified for ATConverter's dayAbbreviations
  //      and/or dayNames options, they should nonetheless begin with the
  //      value for Sunday.
  //
  //    labelDayOfMonth - the label for the day-of-month "buttons".
  //      Can be any HTML!  If not specified, "Day of Month" is assumed.
  //
  //    labelDismiss - the label for the dismiss "button" (if placement is
  //      "popup"). Can be any HTML!  If not specified, "X" is assumed.
  //
  //    labelHour - the label for the hour "buttons".
  //      Can be any HTML!  If not specified, "Hour" is assumed.
  //
  //    labelMinute - the label for the minute "buttons".
  //      Can be any HTML!  If not specified, "Minute" is assumed.
  //
  //    labelMonth - the label for the month "buttons".
  //      Can be any HTML!  If not specified, "Month" is assumed.
  //
  //    labelSecond - the label for the second "buttons".
  //      Can be any HTML!  If not specified, "Second" is assumed.
  //      This option is ignored if askSecond is false!
  //
  //    labelTitle - the label for the "title bar".  Can be any HTML!
  //      If not specified, then whichever of the following is most
  //      appropriate is used:  "Select a Date and Time", "Select a Date"
  //      or "Select a Time", or no label if only one field is present.
  //
  //    labelYear - the label for the year "buttons".
  //      Can be any HTML!  If not specified, "Year" is assumed.
  //
  //    latest - String or Date object representing the latest date/time
  //        that a user can select.  For best results if the field is only
  //        used to specify a date, be sure to set the time to 23:59:59.
  //        If a String is used, it will be parsed according to the widget's
  //        format (see ATConverter#format).
  //
  //    placement - One of the following strings:
  //
  //      "popup" = the widget appears above its <input> when the input
  //        receives focus, and disappears when it is dismissed.  This is
  //        the default behavior.
  //
  //      "inline" = the widget is placed immediately after the <input>
  //        and remains visible at all times.  When choosing this placement,
  //        it is best to make the <input> invisible and use only the
  //        widget to select dates.  The <input> value can still be used
  //        during form submission as it will always reflect the current
  //        widget state.
  //
  //        WARNING: when using "inline" and XHTML and including a day-of-
  //        the-month format field, the input may only appear where a <table>
  //        element is permitted (for example, NOT within a <p> element).
  //        This is because the widget uses a <table> element to arrange
  //        the day-of-the-month (calendar) buttons.  Failure to follow this
  //        advice may result in an "unknown error" in Internet Explorer.
  //
  //    url - specifies a URL to pass to Prototype's Ajax.Request whenever
  //      the user dismisses a popup widget or selects a value in an inline
  //      widget.  The input's name and value are passed as a parameter,
  //      and the "onSuccess" handler sets the input's value to the
  //      responseText. Therefore, the text returned by the server must be
  //      valid for the input's date/time format, and the server can approve
  //      or veto the value chosen by the user. For more information, see:
  //      http://www.prototypejs.org/api/ajax/request
  //      See also option "ajaxOptions" for information about passing
  //      options to the Ajax.Request object.
  //
  //  The following additional options may be specified; see documentation
  //  for base class ATConverter#initialize() for information
  //  about these options:
  //
  //    dayAbbreviations
  //    dayNames
  //    eraAbbreviations
  //    format
  //    monthAbbreviations
  //    monthNames
  //
  //  Other behavior, such as how to format the values on the display
  //  and which "buttons" to include, is inferred from the format string.
  //--------------------------------------------------------------------------

  initialize: function( $super, id, options )
  {
    //  Call the superclass constructor and initialize any options.

    if ( ! options )
      options = {};

    $super( options );

    if ( options.placement )
    {
      if ( options.placement == 'inline' )
        this.pop = false;
      else if ( options.placement != 'popup' )
        throw new Exception('unknown placement: ' + options.placement);
    }

    if ( options.url )
    {
      this.url = options.url;
      if ( options.ajaxOptions )
        this.ajaxOpts = options.ajaxOptions;
    }
    
    if ( options.earliest )
    {
      if ( typeof options.earliest.getTime == 'function' )
        this.earliest = options.earliest.getTime();
      else
        this.earliest = this.parse( options.earliest.toString() );
    }

    if ( options.firstDOW )
    {
      if ( ( options.firstDOW < 0 ) || ( options.firstDOW > 6 ) )
        throw new Exception('illegal firstDOW: ' + options.firstDOW); 
      this.fDOW = options.firstDOW;
    }

    if ( options.latest )
    {
      if ( typeof options.latest.getTime == 'function' )
        this.latest = options.latest.getTime();
      else
        this.latest = this.parse( options.earliest.toString() );
    }

    this.lX = options.labelDismiss || 'X';
    this.labelYear = options.labelYear || 'Year';

    //  Infer what we can about what to display from the format.

    var i;
    var t;
    var lab;
    var shownFields = 0;
    var format = this.fmt;

    if ( typeof options.askEra != 'undefined' )
      this.askEra = options.askEra;
    else
      this.askEra = (format.indexOf('%B')>=0) || (format.indexOf('%C')>=0) || (format.indexOf('%E')>=0);
    var askYear = (format.indexOf('%Y')>=0) || (format.indexOf('%y')>=0) || (format.indexOf('%Z')>=0) || (format.indexOf('%z')>=0);
    var askMonth = (format.indexOf('%b')>=0) || (format.indexOf('%c')>=0) || (format.indexOf('%M')>=0) || (format.indexOf('%m')>=0);
    var askDoM = (format.indexOf('%D')>=0) || (format.indexOf('%d')>=0) || (format.indexOf('%e')>=0);
    var askDate = askYear || askMonth || askDoM;
    this.twelveHour = (format.indexOf('%h')>=0) || (format.indexOf('%I')>=0) || (format.indexOf('%l')>=0) || (format.indexOf('%r')>=0);
    var askHour = this.twelveHour || (format.indexOf('%H')>=0) || (format.indexOf('%k')>=0) || (format.indexOf('%T')>=0);
    var askMinute = (format.indexOf('%i')>=0) || (format.indexOf('%r')>=0) || (format.indexOf('%T')>=0);
    var askSec = ( (format.indexOf('%r')>=0) || (format.indexOf('%S')>=0) || (format.indexOf('%s')>=0) || (format.indexOf('%T')>=0) );
    if ( askSec && ( typeof options.askSecond != 'undefined' ) )
      askSec = options.askSecond;
    var askTime = askHour || askMinute || askSec;


    //  Create the widget HTML and add it to the page.
    //  Popup widgets will be moved to the end of the body
    //  once the entire page has loaded.

    this.inp = $(id);
    this.id = 'Atw_' + id;
    this.div = new Element( 'div', {'class':'AtwWindow AtwWidget', 'id':this.id } );
    this.useTabIndex = (1+this.inp.getAttribute('tabindex')) || 1;
    this.inp.writeAttribute('tabindex');
    this.divsHigh = 0;
    this.divsWide = 0;
 
    if ( this.inp.nextSibling )
      this.inp.parentNode.insertBefore(this.div,this.inp.nextSibling);
    else
      this.inp.parentNode.appendChild(this.div);

    //  Title bar with dismiss box (if popup), and body

    this.title = new Element('h5',{'class':'AtwTitle'});
    this.div.appendChild(this.title);

    var xDiv = null;
    if ( this.pop )
    {
      xDiv = new Element('div',{'class':'AtwDismissBx'});
      this.title.appendChild(xDiv);
      t = new Element('a', {'class':'AtwDismissLnk','title':'OK'}).update(this.lX);
      t.buttonKeypressHandler = this.dismiss.bindAsEventListener(this);
      xDiv.appendChild(t);
      Event.observe(xDiv,'click',this.dismiss.bindAsEventListener(this));
      Event.observe(xDiv,'keypress',this.keyWrap.bindAsEventListener(this));
      Event.observe(t,'focus', function(e) { e.element().parentNode.addClassName('AtwFocusBx'); } );
      Event.observe(t,'blur', function(e) { e.element().parentNode.removeClassName('AtwFocusBx'); } );
    }

    var bodyDiv = new Element('div',{'class':'AtwBody'});
    this.div.appendChild(bodyDiv);

    this.dD = null;
    this.dH = null;
    this.dM = null;
    this.dS = null;
    
    //  date (calendar) portion

    if ( askDate )
    {
      this.dD = new Element( 'div', {'class':'AtwDate' } );
      bodyDiv.appendChild(this.dD);

      if ( askYear )
      {
        this.yLab = (new Element( 'h6', {'class':'AtwLbl AtwLblYr'} )).update( this.labelYear );
        this.dD.appendChild(this.yLab);

        var yearsDiv = new Element( 'div', {'class':'AtwYrs' } );
        this.dD.appendChild( yearsDiv );

        this.yPast = this.button('&lt;',this.newYear,['AtwYrsPast'],'- '+this.labelYear);
        yearsDiv.appendChild( this.yPast );

        t = this.button('1',this.newYear,['AtwYrPrior'],this.labelYear);
        yearsDiv.appendChild(t);
        this.yPrior = t.firstChild;

        t = this.button('2',this.newYear,['AtwYrCurrent'],this.labelYear);
        yearsDiv.appendChild(t);
        this.yCur = t.firstChild;
        t.addClassName('AtwCurrentBx');
        t.firstChild.addClassName('AtwCurrentLnk');

        t = this.button('3',this.newYear,['AtwYrNext'],this.labelYear);
        yearsDiv.appendChild(t);
        this.yNext = t.firstChild;

        this.yAhead = this.button('&gt;',this.newYear,['AtwYrsAhead'],'+ '+this.labelYear);
        yearsDiv.appendChild( this.yAhead );

        shownFields++;
        this.divsHigh++;

      } // if ( askYear )

      if ( askMonth )
      {
        lab = options.labelMonth || 'Month';
        t = (new Element('h6',{'class':'AtwLbl AtwLblMonth'})).update(lab);
        this.dD.appendChild(t);

        var monthsDiv = new Element( 'div', {'class':'AtwMons' } );
        this.dD.appendChild( monthsDiv );

        for ( i = 0 ; i < 12 ; i++ )
          monthsDiv.appendChild( this.button(this.mAbbr[i], this.newMonth,['AtwMon','AtwMon'+String(i+1)],lab+' '+this.mNames[i]) );

        shownFields++;
        this.divsHigh++;
      }

      if ( askDoM )
      {
        lab = options.labelDayOfMonth || 'Day of Month' ;
        t = (new Element('h6',{'class':'AtwLbl AtwLblDoM'})).update(lab);
        this.dD.appendChild(t);

        var domTable = new Element( 'table', {'border':'0','cellpadding':'0','cellspacing':'0','class':'AtwDoMTable'});
        this.dD.appendChild( domTable );

        t = new Element( 'thead', {'class':'AtwDoMHead'} );
        domTable.appendChild( t );

        tr = new Element('tr',{'class':'AtwDoW'} );
        t.appendChild(tr);

        var tbody = new Element( 'tbody', {'class':'AtwDoMBody'} );
        domTable.appendChild( tbody );

        for ( i = 0 ; i < 7 ; i++ )
          tr.appendChild( new Element( 'th', {'class':'AtwDoW AtwDoW'+String(i+1)}).update(this.dAbbr[(this.fDOW+i)%7]));

        for ( var r = 0 ; r < 6 ; r++ )
        {
          tr = new Element('tr',{'class':'AtwWk AtwWk'+String(r+1)});
          tbody.appendChild(tr);
          for ( i = 0 ; i < 7 ; i++ )
            tr.appendChild(new Element('td',{'class':'AtwDoMCell'})).appendChild(this.button('x',this.newDayOfMonth,['AtwDoM'],lab));
        }

        shownFields++;
        this.divsHigh++;

      } // if ( askDoM )

      this.divsWide++;

    } // if ( askDate )

    //  time portion

    if ( askTime )
    {
      var timeDiv = new Element('div',{'class':'AtwTime'});
      bodyDiv.appendChild(timeDiv);

      if ( askHour )
      {
        lab = options.labelHour || 'Hour'; 
        this.dH = new Element('div',{'class':'AtwHrs'});
        timeDiv.appendChild(this.dH);

        this.dH.appendChild((new Element('h6',{'class':'AtwLbl AtwLblHr'})).update(lab) );

        var amDiv = new Element('div',{'class':'AtwHrsAm'});
        this.dH.appendChild( amDiv );
        var pmDiv = new Element('div',{'class':'AtwHrsPm'});
        this.dH.appendChild( pmDiv );

        for ( i = 0 ; i < 12 ; i++ )
        {
          if ( this.twelveHour )
          {
            if ( i == 0 )
              t = '12am';
            else
              t = String(i)+'am';
          }
          else
            t = this.pad(i,2);

          amDiv.appendChild( this.button( t, this.newHour,['AtwHr','AtwHr'+String(i)],lab+' '+t) );

          if ( this.twelveHour )
          {
            if ( i == 0 )
              t = '12pm';
            else
              t = String(i)+'pm';
          }
          else
            t = i+12;

          pmDiv.appendChild( this.button( t, this.newHour,['AtwHr','AtwHr'+String(i)],lab+' '+t) );
        }

        shownFields++;
        this.divsWide++;

      } // if ( askHour )

      if ( askMinute )
      {
        lab = options.labelMinute || 'Minute';
        this.dM = new Element('div',{'class':'AtwMins'});
        timeDiv.appendChild(this.dM);
        this.dM.appendChild((new Element('h6',{'class':'AtwLbl AtwLblMin'}) ).update(lab) );
        var tensDiv = new Element('div',{'class':'AtwMinsTens'});
        this.dM.appendChild(tensDiv);

        for ( i = 0 ; i < 6 ; i++ )
          tensDiv.appendChild( this.button( i, this.newMinuteTens,['AtwMinTen','AtwMin'+i+'0'],lab+' '+i+'0') );

        var onesDiv = new Element('div',{'class':'AtwMinsOnes'});
        this.dM.appendChild(onesDiv);
        for ( i = 0 ; i < 10 ; i++ )
          onesDiv.appendChild( this.button( i, this.newMinuteOnes,['AtwMinOne','AtwMin'+i],lab+' '+i) );

        shownFields++;
        this.divsWide++;

      } // if ( askMinute )

      if ( askSec )
      {
        lab = options.labelSecond || 'Second';
        this.dS = new Element('div',{'class':'AtwSecs'});
        timeDiv.appendChild(this.dS);
        this.dS.appendChild((new Element('h6',{'class':'AtwLbl AtwLblSec'}) ).update(lab) );
        var tensDiv = new Element('div',{'class':'AtwSecsTens'});
        this.dS.appendChild(tensDiv);

        for ( i = 0 ; i < 6 ; i++ )
          tensDiv.appendChild( this.button( i, this.newSecondTens,['AtwSecTen','AtwSec'+i+'0'],lab+' '+i+'0') );

        var onesDiv = new Element('div',{'class':'AtwSecsOnes'});
        this.dS.appendChild(onesDiv);
        for ( i = 0 ; i < 10 ; i++ )
          onesDiv.appendChild( this.button( i, this.newSecondOnes,['AtwSecOne','AtwSec'+i],lab+' '+i) );

        shownFields++;
        this.divsWide++;

      } // if ( askSec )

    } // if ( askTime )


    //  Set the title.  If a title option has been specified, use it.
    //  Otherwise, determine a worthy title based on which (and how many)
    //  format fields have been specified.

    if ( options.labelTitle )
      this.title.insert( options.labelTitle );
    else if ( shownFields > 1 )
      this.title.insert( 'Select a '+(askDate?(askTime?'Date and Time':'Date'):'Time') );
    else
      this.title.insert( '&nbsp;' );


    //  Initialize the widget's date/time value.

    try
    {
      this.time = this.parse(this.inp.value);
    }
    catch ( e )
    {
      this.time = new Date();
    }
    this.lastAjax = this.time;


    //  If this is a popup widget, hide it until needed and set the dismiss
    //  button's tabindex. Otherwise, update the widget to reflect the input
    //  field's initial value.

    if ( this.pop )
    {
      this.div.hide();
      if ( ATWidgetIframe )
        ATWidgetIframe.hide();
      this.div.setStyle( { 'position' : 'absolute' } );
      xDiv.down('a').writeAttribute({'tabindex':++this.useTabIndex});
    }


    //  Setup event listeners for the input and resize listeners for
    //  the widget.  At the widget to the instances list (which is used
    //  to hide widgets if the user clicks off of them).

    Event.observe( this.inp, 'focus',this.showCal.bindAsEventListener(this) );
    //Event.observe( this.inp, 'keypress', function(e){Event.stop(e);} );
    Event.observe( this.div, 'click', function(e){Event.stop(e);} );
    Event.observe( this.div, 'keypress', this.keyWrap.bindAsEventListener(this)); // works in IE+Opera
    Event.observe( window, 'resize', this.pos.bindAsEventListener(this) );
    ATWidgetInstances.set( this.id, this );

  }, // ATWidget#initialize()

  //-------------------------------------------------------------------------
  //  ATWidget#ajax() is called internally whenever Ajax.Request should be
  //  used to notify the server of a value change.
  //-------------------------------------------------------------------------

  ajax: function()
  {
    if ( this.url && ( this.time.getTime() != this.lastAjax.getTime() ) )
    {
      try
      {
        var options = this.ajaxOpts;
        options.parameters = $H( options.parameters || {} );
        options.parameters.set( this.inp.name || this.inp.id, this.inp.value );
        var me = this;
        if ( ! options.onSuccess )
          options.onSuccess = function(xhr) { me.inp.value = xhr.responseText; };
        new Ajax.Request( this.url, options );
        this.lastAjax = this.time;
      }
      catch( e )
      {
      }
    }
  },

  //-------------------------------------------------------------------------
  //  ATWidget#askYear() is called internally by #newYear whenever
  //  a user clicks the yearsPast or yearsAhead button.
  //-------------------------------------------------------------------------

  askYear: function( event )
  {
    if ( ! this.yDiv )
    {
      var totW = 0;
      var divsWide = 0;
      var dims = this.div.getDimensions();
      this.cloak = new Element( 'div', {'class':'AtwCloak' } );
      this.div.appendChild( this.cloak );
      this.cloak.setStyle( { position: 'absolute' } );

      this.yDiv = new Element('div',{'class':'AtwWindow AtwYrSelector'});
      this.div.appendChild(this.yDiv);
      this.yDiv.setStyle( { position: 'absolute' } );

      var title = new Element('h5',{'class':'AtwTitle AtwTitleYrSelector'});
      this.yDiv.appendChild( title );

      var xDiv = new Element('div',{'class':'AtwDismissBx'});
      title.insert(xDiv);
      t = new Element('a', {'class':'AtwDismissLnk','title':'OK'}).update(this.lX);
      t.buttonKeypressHandler = this.dismissYDiv.bindAsEventListener(this);
      xDiv.appendChild(t);
      Event.observe(xDiv,'click',this.dismissYDiv.bindAsEventListener(this));
      Event.observe(xDiv,'keypress',this.keyWrap.bindAsEventListener(this));
      Event.observe(this.cloak,'click',this.dismissYDiv.bindAsEventListener(this));
      Event.observe(this.cloak,'keypress',this.keyWrap.bindAsEventListener(this));
      Event.observe(t,'focus', function(e) { e.element().parentNode.addClassName('AtwFocusBx'); } );
      Event.observe(t,'blur', function(e) { e.element().parentNode.removeClassName('AtwFocusBx'); } );

      title.insert( { bottom: this.labelYear } );

      var yBody = new Element('div',{'class':'AtwBody AtwBodyYrSelector'});
      this.yDiv.appendChild( yBody );

      cont = new Element('div',{'class':'AtwYrMil'});
      yBody.appendChild(cont);
      totW += cont.getWidth();
      divsWide++;
      this.y0XXX = this.button( 0, this.newYPos,['AtwMil','AtwMil0'],this.labelYear+' '+0+'000');
      cont.appendChild(this.y0XXX);
      for ( i = 1; i < 10 ; i++ )
        cont.appendChild( this.button( i, this.newYPos,['AtwMil','AtwMil'+i],this.labelYear+' '+i+'000') );

      cont = new Element('div',{'class':'AtwYrCent'});
      yBody.appendChild(cont);
      totW += cont.getWidth();
      divsWide++;
      for ( i = 0 ; i < 10 ; i++ )
        cont.appendChild( this.button( i, this.newYPos,['AtwCent','AtwCent'+i],this.labelYear+' '+i+'00') );

      cont = new Element('div',{'class':'AtwYrDec'});
      yBody.appendChild(cont);
      totW += cont.getWidth();
      divsWide++;
      for ( i = 0 ; i < 10 ; i++ )
        cont.appendChild( this.button( i, this.newYPos,['AtwDec','AtwDec'+i],this.labelYear+' '+i+'0') );

      cont = new Element('div',{'class':'AtwYrYr'});
      yBody.appendChild(cont);
      totW += cont.getWidth() + 2;
      for ( i = 0 ; i < 10 ; i++ )
        cont.appendChild( this.button( i, this.newYPos,['AtwYr','AtwYr'+i],this.labelYear+' '+i) );

      if ( this.askEra )
      {
        cont = new Element('div',{'class':'AtwYrEra'});
        yBody.appendChild(cont);
        totW += cont.getWidth();
        divsWide++;

        cont.appendChild( this.button( this.eAbbr[0],this.newBCE,['AtwEra','AtwBCE'],this.eAbbr[0]) );
        cont.appendChild( this.button( this.eAbbr[1],this.newCE,['AtwEra','AtwCE'],this.eAbbr[1]) );
      }

      if ( Prototype.Browser.IE )
        totW += (divsWide*3);
      else
        totW += (divsWide);

      this.yDiv.setStyle( { width: String(totW+4)+'px' } );

      if ( title.getWidth() < totW )
        title.setStyle({width:totW+'px'}); // IE quirk

      xDiv.down('a').writeAttribute({'tabindex':++this.useTabIndex});

    } // if ( ! this.yDiv )
    else
    {
      this.cloak.show();
      this.yDiv.show();
    }
    this.pos(event);
    this.updYDiv();
    this.y0XXX.down('.AtwBtnLnk').focus();

  }, // ATWidget#askYear()

  //-------------------------------------------------------------------------
  //  ATWidget#button() is called by #initialize() to create a <div> element
  //  containing an <a> element.  The elements are given appropriate classes
  //  based on the specified "classes" (an array of strings).  The specified
  //  "text" and "title" are used for the <a> element.  The "handler" is bound
  //  to click events for the <div>, which will catch bubbling clicks from
  //  the <a> as well.  The <div> element is returned.
  //-------------------------------------------------------------------------

  button: function( text, handler, classes, title )
  {
    var div = new Element( 'div', {'class':'AtwBtnBx'} );
    var a = new Element( 'a', {'class':'AtwBtnLnk','tabindex':++this.useTabIndex,'title':title } );
    a.update(text);
    div.appendChild(a);
    $A( classes ).each(
      function(c)
      {
        div.addClassName(c+'Bx');
        a.addClassName(c+'Lnk');
      } );
    Event.observe(div,'click',handler.bindAsEventListener(this));
    a.buttonKeypressHandler = handler.bindAsEventListener(this);
    Event.observe(div,'keypress',this.keyWrap.bindAsEventListener(this));
    Event.observe(a,'focus', function(e) { e.element().parentNode.addClassName('AtwFocusBx'); } );
    Event.observe(a,'blur', function(e) { e.element().parentNode.removeClassName('AtwFocusBx'); } );
    return div;
  }, // button

  //-------------------------------------------------------------------------
  //  ATWidget#dismiss() is called internally whenever a user clicks the
  //  button to dismiss the widget.
  //-------------------------------------------------------------------------

  dismiss: function( event )
  {
    if ( this.pop )
    {
      this.div.hide();
      if ( ATWidgetIframe )
        ATWidgetIframe.hide();
      if ( this.yDiv && this.yDiv.visible() )
        this.dismissYDiv(event);
    }
    Event.stop(event);
    this.ajax();
  },

  //-------------------------------------------------------------------------
  //  ATWidget#dismissYDiv() is called internally whenever a user
  //  clicks the button to dismiss the date selector div.
  //-------------------------------------------------------------------------

  dismissYDiv: function(event)
  {
    this.yDiv.hide();
    this.cloak.hide();
    Event.stop(event);
    if ( this.yCur.visible() )
      this.yCur.focus();
  },

  //-------------------------------------------------------------------------
  //  ATWidget#keyWrap() is called internally whenever a user
  //  presses a key while a "button" has focus.  If the key is space, enter
  //  or return, the button is selected as though clicked.  If the key is
  //  ESC and the ATWidget is a popup, the widget is dismissed.
  //-------------------------------------------------------------------------

  keyWrap : function(event)
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    var key = event.keyCode || event.which;
    if ( (key==Event.KEY_RETURN) || (String.fromCharCode(key)==' ') )
      elem.buttonKeypressHandler(event);
    else if ( key == Event.KEY_ESC )
    {
      if ( elem.up('.AtwYrSelector') )
        this.dismissYDiv(event);
      else
        this.dismiss(event);
    }
  }, // keyWrap

  //-------------------------------------------------------------------------
  //  ATWidget#newDayOfMonth() is called internally whenever a user clicks
  //  a date (day of the month) value.  It changes the date and updates
  //  the text field.
  //-------------------------------------------------------------------------

  newDayOfMonth: function( event )
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    var t = elem.innerHTML;
    if ( t != '&nbsp;' )
    {
      var dom = Number(t);
      if ( dom > 0 )
      {
        t = new Date(this.time.getTime());
        t.setDate(dom);
        if ( this.set(t) )
          this.upd();
      }
    }
    elem.focus();
    Event.stop(event);
    return;
  },

  //-------------------------------------------------------------------------
  //  ATWidget#newBCE() is called internally whenever a user
  //  clicks the BCE button.  It changes the date and updates the text field.
  //-------------------------------------------------------------------------

  newBCE: function( event )
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    var year = this.time.getFullYear();
    if ( year > 0 )
    {
      var t = new Date(this.time.getTime());
      t.setFullYear(0-year);
      if ( this.set(t) )
        this.updYDiv();
    }
    elem.focus();
    Event.stop(event);
  },

  //-------------------------------------------------------------------------
  //  ATWidget#newCE() is called internally whenever a user
  //  clicks the CE button.  It changes the date and updates the text field.
  //-------------------------------------------------------------------------

  newCE: function( event )
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    year = this.time.getFullYear();
    if ( year < 0 )
    {
      var t = new Date(this.time.getTime());
      t.setFullYear(0-year);
      if ( this.set(t) )
        this.updYDiv();
    }
    elem.focus();
    Event.stop(event);
  },

  //-------------------------------------------------------------------------
  //  ATWidget#newHour() is called internally whenever a user clicks
  //  an hour value.  It changes the date and updates the text field.
  //-------------------------------------------------------------------------

  newHour: function( event )
  {
    var h;
    var t;
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    if ( ! this.twelveHour )
      h = Number(elem.innerHTML);
    else
    {
      var str = elem.innerHTML;
      t = str.indexOf('a');
      if ( t < 0 )
      {
        t = Number(str.substr(0,str.indexOf('p')));
        h = ( (t==12) ? 12 : (t+12) );
      }
      else
      {
        t = Number(str.substr(0,t));
        h = ( (t==12) ? 0 : t );
      }
    }
    t = new Date(this.time.getTime());
    t.setHours(h);
    if ( this.set(t) )
      this.upd();
    elem.focus();
    Event.stop(event);
  },

  //-------------------------------------------------------------------------
  //  ATWidget#newMinuteOnes() is called internally whenever a user
  //  clicks a minutes ("ones") value.  It changes the date and updates
  //  the text field.
  //-------------------------------------------------------------------------

  newMinuteOnes: function( event )
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    var t = new Date(this.time.getTime());
    t.setMinutes( (Math.floor(this.time.getMinutes()/10)*10)+Number(elem.innerHTML) );
    if ( this.set(t) )
      this.upd();
    elem.focus();
    Event.stop(event);
  },

  //-------------------------------------------------------------------------
  //  ATWidget#newMinuteTens() is called internally whenever a user
  //  clicks a tens-of-minutes value.  It changes the date and updates
  //  the text field.
  //-------------------------------------------------------------------------

  newMinuteTens: function( event )
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    var t = new Date(this.time.getTime());
    t.setMinutes( (Number(elem.innerHTML)*10) + (this.time.getMinutes()%10) );
    if ( this.set(t) )
      this.upd();
    elem.focus();
    Event.stop(event);
  },

  //-------------------------------------------------------------------------
  //  ATWidget#newMonth() is called internally whenever a user clicks
  //  a month.  It changes the date and updates the text field.
  //-------------------------------------------------------------------------

  newMonth: function( event )
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    var t = new Date(this.time.getTime());
    t.setMonth( this.mNums.get(elem.innerHTML) );
    if ( this.set(t) )
      this.upd();
    elem.focus();
    Event.stop(event);
  },

  //-------------------------------------------------------------------------
  //  ATWidget#newSecondOnes() is called internally whenever a user
  //  clicks a Seconds ("ones") value.  It changes the date and updates
  //  the text field.
  //-------------------------------------------------------------------------

  newSecondOnes: function( event )
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    var t = new Date(this.time.getTime());
    t.setSeconds( (Math.floor(this.time.getSeconds()/10)*10) + Number(elem.innerHTML) );
    if ( this.set(t) )
      this.upd();
    elem.focus();
    Event.stop(event);
  },

  //-------------------------------------------------------------------------
  //  ATWidget#newSecondTens() is called internally whenever a user
  //  clicks a tens-of-Seconds value.  It changes the date and updates
  //  the text field.
  //-------------------------------------------------------------------------

  newSecondTens: function( event )
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    var t = new Date(this.time.getTime());
    t.setSeconds( (Number(elem.innerHTML)*10) + (this.time.getSeconds()%10) );
    if ( this.set(t) )
      this.upd();
    elem.focus();
    Event.stop(event);
  },

  //-------------------------------------------------------------------------
  //  ATWidget#newYear() is called internally whenever a user clicks
  //  a year (or one of the "arrows") to shift the year.  It changes the
  //  date and updates the text field.
  //-------------------------------------------------------------------------

  newYear: function( event )
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>
    var txt = elem.innerHTML;
    if ( ( txt == '<' ) || ( txt == '&lt;' ) )
      this.askYear(event);
    else if ( ( txt == '>' ) || ( txt == '&gt;' ) )
      this.askYear(event);
    else
    {
      var t = new Date(this.time.getTime());
      t.setFullYear(Number(txt));
      if ( this.set(t) )
        this.upd();
      elem.focus();
    }
    Event.stop(event);
  },

  //-------------------------------------------------------------------------
  //  ATWidget#newYPos() is called internally whenever a user clicks a year
  //  selection value.  It changes the date and updates the text field.
  //-------------------------------------------------------------------------

  newYPos: function( event )
  {
    var elem = event.element();
    if ( elem.nodeName.toUpperCase() == 'DIV' )
      elem = elem.firstChild; // <a> within <div>

    var era = 1;
    var year = this.time.getFullYear();
    if ( year < 0 )
    {
      era = (-1);
      year = 0 - year;
    }
    year = this.pad( year, 4 );
    if ( elem.hasClassName('AtwMilLnk') )
      year = elem.innerHTML + year.substring(1,4);
    else if ( elem.hasClassName('AtwCentLnk') )
      year = year.substring(0,1) + elem.innerHTML + year.substring(2,4);
    else if ( elem.hasClassName('AtwDecLnk') )
      year = year.substring(0,2) + elem.innerHTML + year.substring(3,4);
    else
      year = year.substring(0,3) + elem.innerHTML;
    if ( year == '0000' )
      year = 1;
    var t = new Date(this.time.getTime());
    t.setFullYear( era * year );
    if ( this.set(t) )
      this.updYDiv();
    elem.focus();
    Event.stop(event);
  },

  //-------------------------------------------------------------------------
  //  ATWidget#pos() is called internally whenever the widget needs
  //  to be positioned, such as when it is displayed or when the window
  //  is resized.
  //-------------------------------------------------------------------------

  pos: function(event) // note: event is ignored but this is a handler
  {
    if ( this.pop )
    {
      var off = this.inp.cumulativeOffset();
      var bodyWidth = $(document.body).getWidth();
      var widgetWidth = this.div.getWidth();
      var left = off.left;
      if ( left + widgetWidth > bodyWidth - 20 )
        left = bodyWidth - ( widgetWidth + 20 );
      var top = off.top - this.div.getHeight();
      if ( top < 0 )
        top = off.top + this.inp.getHeight();
      this.div.setStyle( { "top": String(top)+"px", "left": String(left<0?0:left)+"px" } );
    }

    if ( this.yDiv )
    {
      this.cloak.clonePosition( this.div );
      var dims = this.cloak.getDimensions();
      this.cloak.setStyle( { height: dims.height-2, width: dims.width-2 } );
      var off = ( this.yLab.getWidth() - this.yDiv.getWidth() ) / 2;
      this.yDiv.clonePosition( this.yLab, { setWidth:false, setHeight:false, offsetLeft: (off<0)?0:off } ) ;
    }

  }, // ATWidget#pos()

  //-------------------------------------------------------------------------
  //  ATWidget#set() is called internally to change the current time.
  //  It returns true if the new time is within the allowed range (if any).
  //-------------------------------------------------------------------------

  set: function(newTime)
  {
    var t = newTime.getTime();
    if ( this.earliest && ( t < this.earliest ) )
      return false;
    if ( this.latest && ( t > this.latest ) )
      return false;
    this.time = newTime;
    return true;
    
  }, // ATWidget#set()
  
  //-------------------------------------------------------------------------
  //  ATWidget#showCal() is called internally whenever a user clicks the
  //  associated text field to display the widget.  The current value in
  //  the field is used to initialize the widget.
  //-------------------------------------------------------------------------

  showCal: function(event)
  {
    try
    {
      this.time = this.parse(this.inp.value);
    }
    catch ( e )
    {
      this.time = new Date();
    }

    this.upd();
    this.pos(event);

    if ( this.pop && ATWidgetIframe )
      setTimeout( "ATWidgetIframeAdjust('"+this.div.id+"')", 1 );

    var a = this.div.down('.AtwYrCurrentLnk');
    if ( ! a )
      a = this.div.down('.AtwBtnLnk');
    a.focus();
    Event.stop(event);

  }, // ATWidget#showCal()
  

  //-------------------------------------------------------------------------
  //  ATWidget#upd() is called internally to update the widget's
  //  appearance.  It is called after most events so the widget always
  //  reflects the currently-selected values.
  //-------------------------------------------------------------------------

  upd: function(cancelAjax)
  {
    var me = this;

    //  Update year.

    var current = this.time.getFullYear();
    if ( this.yPrior )
      this.yPrior.update(me.pad((current==1)?(-1):(current-1),4));
    if ( this.yCur )
      this.yCur.update(me.pad(current,4));
    if ( this.yNext )
      this.yNext.update(me.pad((current==-1)?1:(current+1),4));

    //  Update month.

    var i = 0;
    current = this.time.getMonth();
    $$('#'+this.id+' .AtwMonLnk').each(
      function(elem)
      {
        me.updCur( elem, i == current );
        i++;
      } );

    //  Update days.

    current = this.time.getDate();
    var currentMonth = this.time.getMonth();
    var dom = new Date(this.time.getTime());
    dom.setDate(1);
    var dow1 = dom.getDay();
    if ( me.fDOW > dow1 )
      dow1 += 7;
    var wom = 0, dow=0;
    $$('#'+this.id+' .AtwWk').each(
      function(row)
      {
        dow = me.fDOW;
        for ( td = row.down(); dow - me.fDOW < 7 ; td = td.next() )
        {
          var a = td.down('a');
          if ( ((wom==0)&&(dow<dow1)) || (dom.getMonth()!=currentMonth) )
          {
            a.update('&nbsp;');
            a.removeClassName('AtwDoMLnkFilled');
            a.removeClassName('AtwCurrentLnk');
            a.addClassName('AtwDoMLnkEmpty');
            a.parentNode.removeClassName('AtwDoMBxFilled');
            a.parentNode.addClassName('AtwDoMBxEmpty');
          }
          else
          {
            a.update(dom.getDate());
            a.removeClassName('AtwDoMLnkEmpty');
            a.addClassName('AtwDoMLnkFilled');
            a.parentNode.removeClassName('AtwDoMBxEmpty');
            a.parentNode.addClassName('AtwDoMBxFilled');
            me.updCur( a, dom.getDate() == current );
            dom.setDate(dom.getDate()+1);
          }
          dow++;
        }
        wom++;
      } );

    //  Update hour.

    var h = this.time.getHours();
    $$('#'+this.id+' .AtwHrLnk').each(
      function(elem)
      {
        me.updCur( elem, ( (!this.twelveHour) && (Number(elem.innerHTML)==h) ) || ( elem.innerHTML == String((h==0)?12:((h<=12)?h:(h-12)))+((h<12)?'am':'pm') ) );
      } );

    //  Update minute.

    var mi = this.time.getMinutes();
    var tens = Math.floor(mi/10);
    var ones = mi % 10;
    $$('#'+this.id+' .AtwMinTenLnk').each(
      function(elem)
      {
        me.updCur( elem, elem.innerHTML == String(tens) );
      } );
    $$('#'+this.id+' .AtwMinOneLnk').each(
      function(elem)
      {
        me.updCur( elem, elem.innerHTML == String(ones) );
      } );

    //  Update second.

    var mi = this.time.getSeconds();
    var tens = Math.floor(mi/10);
    var ones = mi % 10;
    $$('#'+this.id+' .AtwSecTenLnk').each(
      function(elem)
      {
        me.updCur( elem, elem.innerHTML == String(tens) );
      } );
    $$('#'+this.id+' .AtwSecOneLnk').each(
      function(elem)
      {
        me.updCur( elem, elem.innerHTML == String(ones) );
      } );

    //  Show change and invoke Ajax.Request if desired.
    //  Size the widget according to its components.

    this.inp.value = this.format( this.time );
    this.div.show();

    var d, totH = totW = 0;
    if ( this.dD )
    {
      d = this.dD.getDimensions();
      totW += d.width;
      totH = d.height;
    }
    if ( this.dH )
    {
      d = this.dH.getDimensions();
      totW += d.width;
      if ( d.height > totH ) totH = d.height;
    }
    if ( this.dM )
    {
      d = this.dM.getDimensions();
      totW += d.width;
      if ( d.height > totH ) totH = d.height;
    }
    if ( this.dS )
    {
      d = this.dS.getDimensions();
      totW += d.width;
      if ( d.height > totH ) totH = d.height;
    }
      
    if ( Prototype.Browser.IE )
    {
      totH += this.title.getHeight() + (this.divsHigh*3);
      totW += (this.divsWide*3);
    }
    else
    {
      totH += this.title.getHeight() + this.divsHigh + 1;
      totW += (this.divsWide*2);
    }
    
    this.div.setStyle({height:totH+'px',width:totW+'px'});
    if ( this.title.getWidth() < totW )
      this.title.setStyle({width:totW+'px'}); // IE quirk
      
    if ( ! this.pop )
      this.ajax();

  }, // ATWidget#upd()

  //-------------------------------------------------------------------------
  //  ATWidget#updCur() is called internally to update buttons based on
  //  whether they reflects the "current" value.
  //-------------------------------------------------------------------------

  updCur: function(link,cur)
  {
    if ( cur )
    {
      link.addClassName('AtwCurrentLnk');
      link.parentNode.addClassName('AtwCurrentBx');
    }
    else
    {
      link.removeClassName('AtwCurrentLnk');
      link.parentNode.removeClassName('AtwCurrentBx');
    }

  }, // ATQAuickCal#updCur()

  //-------------------------------------------------------------------------
  //  ATWidget#updYDiv() is called internally to update the year selector's
  //  appearance.  It is called after most events so the widget always
  //  reflects the currently-selected values.
  //-------------------------------------------------------------------------

  updYDiv: function(event)
  {
    var me = this;
    var era = 1;
    var yearValue = this.time.getFullYear();
    if ( yearValue < 0 )
    {
      era = (-1);
      yearValue = 0 - yearValue;
    }
    yearValue = this.pad( yearValue, 4 );
    $$('#'+this.id+' .AtwMilLnk').each(
      function(elem)
      {
        me.updCur( elem, elem.innerHTML == yearValue.substring(0,1) );
      } );
    $$('#'+this.id+' .AtwCentLnk').each(
      function(elem)
      {
        me.updCur( elem, elem.innerHTML == yearValue.substring(1,2) );
      } );
    $$('#'+this.id+' .AtwDecLnk').each(
      function(elem)
      {
        me.updCur( elem, elem.innerHTML == yearValue.substring(2,3) );
      } );
    $$('#'+this.id+' .AtwYrLnk').each(
      function(elem)
      {
        me.updCur( elem, elem.innerHTML == yearValue.substring(3) );
      } );
    $$('#'+this.id+' .AtwBCELnk').each(
      function(elem)
      {
        me.updCur( elem, era < 0 );
      } );
    $$('#'+this.id+' .AtwCELnk').each(
      function(elem)
      {
        me.updCur( elem, era > 0 );
      } );

    //  Show change

    this.inp.value = this.format( this.time );
    this.upd();

  } // ATWidget#updYDiv()

}); // ATWidget


//  IE6 doesn't float popups over <select> elements unless
//  an <iframe> is inserted between them!  This function
//  moves the <iframe> behind the widget when it is displayed.
//  The function is invoked by a setTimeout() call in 

function ATWidgetIframeAdjust(id)
{
  var div = $(id);
  var dim = div.getDimensions();
  var pos = div.cumulativeOffset();
  ATWidgetIframe.setStyle( {
    "height" : String(dim.height) + "px",
    "left" : String(pos.left) + "px",
    "position" : "absolute",
    "top" : String(pos.top) + "px",
    "width" : String(dim.width) + "px"
    } );
  ATWidgetIframe.show();
}


//  A few things need to be taken care of once the page has
//  completely loaded...

Event.observe( window, 'load',
  function(loadEvent)
  {
	//  Ping the server for statistical purposes (remove if offended).
	
	if ( window.location.hostname.length && ( window.location.hostname != 'www.ama3.com' ) )
	    $(document.body).insert({bottom:'<img src="http://www.ama3.com/anytime/ping/?prototype" width="0" height="0" />'});
  

    //  IE6 doesn't float popups over <select> elements unless
    //  an <iframe> is inserted between them!  The <iframe>
    //  is added to the page *before* the popups are moved,
    //  so they will appear after the <iframe>.
      
    if ( navigator.userAgent.indexOf('MSIE 6') > 0 )
    {
      ATWidgetIframe = $(document.createElement("iframe"));
      ATWidgetIframe.src = "javascript:'<html bgcolor=red></html>';";
      ATWidgetIframe.setAttribute("scrolling","no");
      ATWidgetIframe.setAttribute("frameborder","0");
      ATWidgetIframe.setStyle( {
        "display" : "block",
        "height" : "1px",
        "left" : "0px",
        "top" : "0px",
        "width" : "1px",
        "zIndex" : 0
        } );
        document.body.appendChild(ATWidgetIframe);
      } // if ( navigator.userAgent.indexOf('MSIE 6') > 0 )
      
      
    //  Move popup windows to the end of the page.
    //  This allows them to overcome XHTML restrictions
    //  on <table> placement enforced by MSIE.

    $$('div.AtwWidget').each(
      function(elem)
      {
        var inst = ATWidgetInstances.get(elem.id);
        if ( ! inst.pop )
          inst.upd();
        else if ( inst.parentNode != document.body )
        {
          inst.div.parentNode.removeChild( inst.div );
          document.body.appendChild(inst.div);
        }
      } );

    //  Any click on the page that isn't on a popup widget
    //  should make that widget disappear.

    Event.observe( document, 'click',
      function(clickEvent)
      {
        $$('div.AtwWidget').each(
          function(elem)
          {
            var inst = ATWidgetInstances.get(elem.id);
            if ( clickEvent.element() != inst.inp )
            {
              if ( inst.yDiv )
              {
                inst.yDiv.hide();
                inst.cloak.hide();
              }
              if ( inst.pop )
              {
                inst.div.hide();
                if ( ATWidgetIframe )
                  ATWidgetIframe.hide();
              }
              inst.ajax();
            }
          } );
      } );
      
  } ); // loadEvent

//
//  END OF FILE
//
alert("REMOVE THE LAST LINE FROM anytime.prototype.js!");
