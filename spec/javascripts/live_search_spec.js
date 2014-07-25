describe("liveSearch", function(){
  var $form, $results, _supportHistory, liveSearch;
  var dummyResponse = {
    "count":1,
    "pluralised_document_noun":"reports",
    "applied_filters":" \u003Cstrong\u003ECommercial - rotorcraft \u003Ca href='?format=json\u0026keywords='\u003E×\u003C/a\u003E\u003C/strong\u003E",
    "documents":[
      {
        "title":"Test report",
        "slug":"aaib-reports/test-report",
        "metadata":[
          {
            "label":"Aircraft category",
            "value":"General aviation - rotorcraft",
            "is_text":true
          },{
            "label":"Report type",
            "value":"Annual safety report",
            "is_text":true
          },{
            "label":"Occurred",
            "is_date":true,
            "machine_date":"2013-11-03",
            "human_date":"3 November 2013"
          }
        ]
      }
    ]
  };

  beforeEach(function () {
    $form = $('<form action="/somewhere" class="js-live-search-form"><input type="checkbox" name="field" value="sheep" checked></form>');
    $results = $('<div class="js-live-search-results-block"></div>');

    $('body').append($form).append($results);

    _supportHistory = GOVUK.support.history;
    GOVUK.support.history = function(){ return true; };

    liveSearch = new GOVUK.LiveSearch({$form: $form, $results: $results});
  });

  afterEach(function(){
    $form.remove();
    $results.remove();

    GOVUK.support.history = _supportHistory;
  });

  it("should save initial state", function(){
    expect(liveSearch.state).toEqual([{name: 'field', value: 'sheep'}]);
  });

  it("should detect a new state", function(){
    expect(liveSearch.isNewState()).toBe(false);
    $form.find('input').prop('checked', false);
    expect(liveSearch.isNewState()).toBe(true);
  });

  it("should update state to current state", function(){
    expect(liveSearch.state).toEqual([{name: 'field', value: 'sheep'}]);
    $form.find('input').prop('checked', false);
    liveSearch.saveState();
    expect(liveSearch.state).toEqual([]);
  });

  it("should update state to passed in state", function(){
    expect(liveSearch.state).toEqual([{name: 'field', value: 'sheep'}]);
    $form.find('input').prop('checked', false);
    liveSearch.saveState({ my: "new", state: "object"});
    expect(liveSearch.state).toEqual({ my: "new", state: "object"});
  });

  it("should not request new results if they are in the cache", function(){
    liveSearch.resultCache["more=results"] = "exists";
    liveSearch.state = { more: "results" };
    spyOn(liveSearch, 'displayResults');
    spyOn(jQuery, 'ajax');

    liveSearch.updateResults();
    expect(liveSearch.displayResults).toHaveBeenCalled();
    expect(jQuery.ajax).not.toHaveBeenCalled();
  });

  it("should return a promise like object if results are in the cache", function(){
    liveSearch.resultCache["more=results"] = "exists";
    liveSearch.state = { more: "results" };
    spyOn(liveSearch, 'displayResults');
    spyOn(jQuery, 'ajax');

    var promise = liveSearch.updateResults();
    expect(typeof promise.done).toBe('function');
  });

  it("should return a promise like object if results aren't in the cache", function(){
    liveSearch.state = { not: "cached" };
    spyOn(liveSearch, 'displayResults');
    var ajaxCallback = jasmine.createSpyObj('ajax', ['done', 'error']);
    ajaxCallback.done.and.returnValue(ajaxCallback);
    spyOn(jQuery, 'ajax').and.returnValue(ajaxCallback);

    liveSearch.updateResults();
    expect(jQuery.ajax).toHaveBeenCalledWith({url: '/somewhere.json', data: {not: "cached"}});
    expect(ajaxCallback.done).toHaveBeenCalled();
    ajaxCallback.done.calls.mostRecent().args[0]('response data')
    expect(liveSearch.displayResults).toHaveBeenCalled();
    expect(liveSearch.resultCache['not=cached']).toBe('response data');
  });

  it("should show error indicator when error loading new results", function(){
    liveSearch.state = { not: "cached" };
    spyOn(liveSearch, 'displayResults');
    spyOn(liveSearch, 'showErrorIndicator');
    var ajaxCallback = jasmine.createSpyObj('ajax', ['done', 'error']);
    ajaxCallback.done.and.returnValue(ajaxCallback);
    spyOn(jQuery, 'ajax').and.returnValue(ajaxCallback);

    liveSearch.updateResults();
    ajaxCallback.error.calls.mostRecent().args[0]()
    expect(liveSearch.showErrorIndicator).toHaveBeenCalled();
  });

  it("should return cache items for current state", function(){
    liveSearch.state = { not: "cached" };
    expect(liveSearch.cache('some-slug')).toBe(undefined);
    liveSearch.cache('some-slug', 'something in the cache');
    expect(liveSearch.cache('some-slug')).toBe('something in the cache');
  });

  describe('with relevant dom nodes set', function(){
    beforeEach(function(){
      liveSearch.$form = $form;
      liveSearch.$resultsBlock = $results;
      liveSearch.state = { field: "sheep" };
    });

    it("should update save state and update results when checkbox is changed", function(){
      var promise = jasmine.createSpyObj('promise', ['done']);
      spyOn(liveSearch, 'updateResults').and.returnValue(promise);
      //spyOn(liveSearch, 'pageTrack').and.returnValue(promise);
      $form.find('input').prop('checked', false);

      liveSearch.checkboxChange();
      expect(liveSearch.state).toEqual([]);
      expect(liveSearch.updateResults).toHaveBeenCalled();
      promise.done.calls.mostRecent().args[0]();
      //expect(liveSearch.pageTrack).toHaveBeenCalled();
    });

    it("should do nothing if state hasn't changed when a checkbox is changed", function(){
      spyOn(liveSearch, 'updateResults');
      liveSearch.checkboxChange();
      expect(liveSearch.state).toEqual({ field: 'sheep'});
      expect(liveSearch.updateResults).not.toHaveBeenCalled();
    });

    it("should display results from the cache", function(){
      liveSearch.resultCache["the=first"] = dummyResponse;
      liveSearch.state = { the: "first" };
      liveSearch.displayResults(dummyResponse);
      expect($results.find('h3').text()).toBe('Test report');
      expect($results.find('.result-count').text()).toMatch(/^\s*1\s*/);
    });
  });
});
