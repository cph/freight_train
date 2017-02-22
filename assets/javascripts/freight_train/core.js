// FreightTrain Core
// =========================================================================================================
//
// Events raised from FT:
//   after_add_nested   raised after a nested item is created
//   after_reset_nested raised after a nested item is either created or destroyed
//   load               raised right after FreightTrain is initialized
//
//
// Events raised from elements
//   ft:create          raised by an element that's just been created by FreightTrain
//   ft:delete          raised by an element that's just been deleted by FreightTrain
//   ft:update          raised by an element that's just been updated by FreightTrain
//   ft:value_assigned  raised by each form element when FreightTrain assigns it's value
//
//
// For every FreightTrain instance created in a page, a namespace will be added to FT that is named after the model.
//
//   e.g. FT.Tag
//
//
// This namespace has one event that can be observed:
//   hookup_row         passes each row to observers: both when the page is loaded and when new rows are added dynamically
//
//
(function() {

  var token = '',
      enable_nested_records = true,
      save_when_navigating = false,
      enable_keyboard_navigation = false,
      enable_ghost_rows = false,
      initialized = false,
      observer = new Observer(),
      forms = [],
      _$ = null;
  
  
  
  
  
  function init(args) {
    initOneTime(args);
    activateFreightTrainForms();
    enable_nested_records && enableNestedEditors();
    observer.fire('load');
  }
  
  
  
  
  
  function initOneTime(args) {
    if(!initialized) {
      readOptions(args);
      enable_keyboard_navigation  && enableKeyboardNavigation();
      respondToInlineEditorEvents();
      activateRowCommands();
      removeDestroyedRows();
      observer.fire('initialized');
      initialized = true;
    }
  }
  
  
  
  function readOptions(args) {
    args = args || {};
    switch(args.adapter) {
      case 'jquery':
        _$ = FT.Adapters.jQuery;
        break;
        
      default:
        _$ = FT.Adapters.Prototype;
        break;
    }
    _$.is_in = function(element, selector) {
      return _$.match(element, selector) || !!_$.up(element, selector);
    }
    FT.$ = _$;
    token = args.token;
    save_when_navigating = args.save_when_navigating;
    enable_keyboard_navigation = args.enable_keyboard_navigation;
    enable_ghost_rows = args.enable_ghost_rows;
  }
  
  
  
  function enableKeyboardNavigation() {
    FT.InlineEditor.observe('up', function(e, row, editor) {
      var previous_row = _$.previous(row, '.editable');
      if(previous_row) {
        _$.stop(e);
        if(save_when_navigating) { editor.save(); }
        previous_row.edit_inline();
      }
    });
    FT.InlineEditor.observe('down', function(e, row, editor) {
      var next_row = _$.next(editor, '.editable');
      if(next_row) {
        _$.stop(e);
        if(save_when_navigating) { editor.save(); }
        next_row.edit_inline();
      }
    });
  }
  
  
  
  function respondToInlineEditorEvents() {
    FT.InlineEditor.observe('after_init', function(element, editor) {
      initializeInlineEditorForModel(element, editor);
      enable_nested_records && enableNestedEditorsIn(editor);
    });
  }
  
  function initializeInlineEditorForModel(tr, tr_edit) {
    var form = _$.up(tr, 'form.freight_train'),
        model = form && getModelFromForm(form);
    model && model.initializeEditor(tr, tr_edit);
  }
  
  
  
  function activateRowCommands() {
    activateDeleteCommand();
  }
  
  function activateDeleteCommand() {
    _$.delegate(document.body, 'click', '.delete-command', function(e) {
      var a     = _$.target(e),
          id    = a && _$.attr(a, 'data-id'),
          form  = a && _$.up(a, 'form.freight_train'),
          model = form && getModelFromForm(form);
      if(model && id) {
        _$.stop(e);
        model && model.destroy(id);
      }
    });
  }
  
  
  
  function removeDestroyedRows() {
    // need to wrap document.body in $() so that it works on IE
    _$.on(document.body, 'ft:destroy', function(event) {
      FT.InlineEditor.close();
      var e = _$.target(event);
      e && e.parentNode && e.parentNode.removeChild(e);
      FT.Helpers.restripeRows();
    });
  }
  
  
  
  
  
  function activateFreightTrainForms() {
    var _forms = findFreightTrainForms();
    for(var i=0, ii=_forms.length; i<ii; i++) {
      activateFreightTrainForm(_forms[i]);
    }
  }
  
  function findFreightTrainForms() {
    return _$.find('form.freight_train');
  }
  
  
  
  function activateFreightTrainForm(form) {
    hasFormBeenInitialized(form) ? reinitializeForm(form) : initializeForm(form);
  }
  
  function hasFormBeenInitialized(form) {
    for(var i=0, ii=forms.length; i<ii; i++) {
      if(forms[i] == form) {
        return true;
      }
    }
    return false;
  }
  
  function reinitializeForm() {
    // Do nothing
  }
  
  function initializeForm(form) {
    configureFormSubmission(form);
    extendFormModel(form);
    initializeRowsInForm(form);
  }
  
  
  
  function configureFormSubmission(form) {
    _$.on(form, 'submit', function(e) {
      _$.stop(e);
      FT.InlineEditor.close(); // Don't let values in inline editor override values in creator
      submitFormRemotely(form);
    })
  }
  
  function submitFormRemotely(form) {
    FT.xhr(form.action, 'post', _$.serialize(form));
  }
  
  
  
  function extendFormModel(form) {
    var model = getModelFromForm(form);
    if(model && !model.extended) {
      model.init();
      model.extended = true;
      var _originalHookupRow = model.hookupRow,
          collection_name = model.collection();
      
      model.addRow = function(content) {
        var list = _$.find_by_id(collection_name),
            new_row = _$.prependTo(list, content);
        model.hookupRow(new_row);
        window.setTimeout(function() {
          _$.hide('#flash_error');
          _$.fire(new_row, 'ft:create')
          FT.Helpers.restripeRows();
        });
      }
      
      model.updateRow = function(id, content) {
        var row = _$.find_by_id(id);
        if(row) {
          _$.replace(row, content);
          model.hookupRow(row);
          window.setTimeout(function() {
            _$.hide('#flash_error');
            _$.fire(row, 'ft:update');
          });
        }
      }
      
      model.deleteRow = function(id) {
        var row = _$.find_by_id(id);
        row && _$.fire(row, 'ft:destroy');
      }
      
      model.updateRows = function(content) {
        var list = _$.find_by_id(collection_name);
        if(list) {
          _$.replace(list, content);
          model.hookupRows();
        }
      }
      
      model.hookupRow = function(row) {
        _$.hasClass(row, 'interactive') && FT.Helpers.hoverRow(row);
        _$.hasClass(row, 'editable') && model.activateEditing && model.activateEditing(row);
        _originalHookupRow && _originalHookupRow(row);
      }
      
      model.hookupRows = function(rows) {
        rows = rows || findRowsWithin(form);
        for(var i=0, ii=rows.length; i<ii; i++) {
          model.hookupRow(rows[i]);
        }
      }
    }
  }
  
  function getModelFromForm(form) {
    var model_name = _$.attr(form, 'data-model'),
        model = FT[model_name];
    model || FT.debug('[ft] FT.' + model_name + ' was not found.');
    return model;
  }
  
  function findRowsWithin(form) {
    return _$.find(form, '.row');
  }
  
  
  
  function initializeRowsInForm(form) {
    var model = getModelFromForm(form)
    model && model.hookupRows && model.hookupRows();
  }
  
  
  
  
  
  function enableNestedEditors() {
    enableNestedEditorsIn(document.body);
  }
  
  function enableNestedEditorsIn(parent) {
    withEach(findNestedEditors(parent), initializeNestedEditor);
  }
  
  function updateNestedEditors() {
    updateNestedEditorsIn(document.body);
  }
  
  function updateNestedEditorsIn(parent) {
    withEach(findNestedEditors(parent), updateNestedEditor);
  }
  
  function findNestedEditors(parent) {
    return _$.find(parent, '.nested.editor');
  }
  
  function initializeNestedEditor(nested_editor) {
    _$.delegate(nested_editor, 'click',    '.add-nested-link', nestedRowAction(addNestedRow));
    _$.delegate(nested_editor, 'click', '.delete-nested-link', nestedRowAction(deleteNestedRow));
    if(nested_editor.hasAttribute('data-ghost-rows') ? nested_editor.getAttribute('data-ghost-rows') == 'true' : enable_ghost_rows) {
      _$.delegate(nested_editor, 'change, keyup', 'input, select', changedNestedRow);
    }
    _$.delegate(nested_editor, 'focus', '*', focusInNestedRow);
    _$.delegate(nested_editor, 'blur', '*', blurInNestedRow);
    updateNestedEditor(nested_editor);
    
    // Hide rows that were created with _destroy="1"
    var deleted_rows = _$.find(nested_editor, '[data-attr="_destroy"][value="1"]');
    for(var i=0, ii=deleted_rows.length, row, input; i<ii; i++) {
      input = deleted_rows[i];
      row = _$.up(input, '.nested-row');
      row && _$.hide(row);
    }
    
    updateNestedRowCount(nested_editor);
  }
  
  function nestedRowAction(action) {
    return function(e) {
      _$.stop(e);
      var row = getNestedRowFromEvent(e);
      row && action(row);
    }
  }
  
  function getNestedRowFromEvent(e) {
    var target = _$.target(e),
        row = target && _$.up(target, '.nested-row');
    row || FT.debug('[getParentNestedRow] .nested-row not found');
    return row;
  }
  
  
  
  function changedNestedRow(e) {
    var row = getNestedRowFromEvent(e);
    if(!row || !row.parentNode) {return;}
    var nested_editor = _$.up(row, '.nested.editor');
    updateNestedRowCount(nested_editor);
  }
  
  function focusInNestedRow(e) {
    var row = getNestedRowFromEvent(e);
    if(!row) { return; }
    _$.addClass(row, 'focused-row');
  }
  
  function blurInNestedRow(e) {
    var row = getNestedRowFromEvent(e);
    if(!row) { return; }
    _$.removeClass(row, 'focused-row');
  }
  
  function updateNestedRowCount(nested_editor) {
    if(nested_editor.hasAttribute('data-ghost-rows') ? nested_editor.getAttribute('data-ghost-rows') != 'true' : !enable_ghost_rows) {
      return;
    }
    if(_$.find(nested_editor, '.nested-row input:visible').length == 0) { return; }
    
    var isEmptyRow = isEmptyNestedRow;
    var isEmptyRowFunction = _$.attr(nested_editor, 'data-is-empty-row');
    if(isEmptyRowFunction) {
      var references = isEmptyRowFunction.split('.');
      var context = window;
      for(var i=0; i<references.length; i++) {
        context = context && context[references[i]];
      }
      context && (isEmptyRow = context);
    }
    
    // How many empty rows are left?
    var rows = _$.find(nested_editor, '.nested-row');
    var empty_rows = [];
    var row;
    for(var i=0, ii=rows.length; i<ii; i++) {
      row = rows[i];
      if(isEmptyRow(row)) {
        (i > 0) && _$.addClass(row, 'empty-row'); // never mark the first row as empty
        empty_rows.push(row);
      } else {
        _$.removeClass(row, 'empty-row');
      }
    }
    
    // If there are no empty rows, create one.
    (rows.length > 0 && empty_rows.length == 0) && addNestedRow(rows[0], {noSelect: true});
    
    // If there is more than one empty row, delete the rest.
    for(var i=1; i<empty_rows.length; i++) {
      deleteNestedRow(empty_rows[i], {noSelect: true});
    }
  }
  
  function isEmptyNestedRow(row) {
    var filled_inputs = 0;
    withEach(_$.find(row, 'input:visible'), function(input) {
      if(input.type == 'hidden' || input.type == 'checkbox' || input.type == 'radio') { return; }
      (input.value == '') || (filled_inputs++);
    });
    return filled_inputs == 0;
  }
  
  function addNestedRow(row, options) {
    if(!row.parentNode) {return;}
    var nested_editor = _$.up(row, '.nested.editor');
    options = options || {};
    
    // Clone a row
    var new_row   = _$.clone(row),
        name      = _$.attr(new_row, 'name').replace(/\[(\d+)\]/, function(m, n){return '['+(Number(n)+1)+']';});
    new_row.id    = row.id.replace(/(\d+)$/, function(m, n){return Number(n) + 1;});
    _$.attr(new_row, 'name', name);
    _$.attr(new_row, 'attr', name);
    _$.removeClass(new_row, 'focused-row');
    _$.addClass(new_row, 'empty-row');
    row.parentNode.appendChild(new_row);
    
    // Reset the cloned row's values
    setNestedRowFieldValue(new_row, '_destroy', 0);
    setNestedRowFieldValue(new_row, 'id', '');
    resetFormFieldsIn(new_row);
    options.noSelect || selectFirstFieldIn(new_row);
    
    observer.fire('after_add_nested', [nested_editor, new_row]);
    updateNestedEditor(nested_editor);
  }
  
  function deleteNestedRow(row, options) {
    if(!row.parentNode) {return;}
    var nested_editor = _$.up(row, '.nested.editor');
    options = options || {};
    
    // How many undeleted records are left? Only 1? Create a new empty record.
    var undeleted_rows = 0;
    withEach(row.parentNode.childNodes, function(row) {
      (getNestedRowFieldValue(row, '_destroy') != '1') && (undeleted_rows++);
    });
    (undeleted_rows <= 1) && addNestedRow(row);
    
    // Give focus either to the previous row or the next row
    var previous_row = _$.previous(row) || _$.next(row);
    options.noSelect || selectFirstFieldIn(previous_row);
    
    // Remove or hide the deleted record
    if(getNestedRowFieldValue(row, 'id')) {
      setNestedRowFieldValue(row, '_destroy', 1);
      _$.hide(row);
    } else {
      row.parentNode.removeChild(row);
    }
    
    observer.fire('after_delete_nested', [nested_editor, row]);
    updateNestedEditor(nested_editor);
  }
  
  function getNestedRowFieldValue(row, attr) {
    var field = getNestedRowField(row, attr);
    return field && field.value;
  }
  
  function setNestedRowFieldValue(row, attr, value) {
    var field = getNestedRowField(row, attr);
    field && (field.value = value);
  }
  
  function getNestedRowField(row, attr) {
    return _$.find(row, '[data-attr="' + attr + '"]')[0];
  }
  
  
  
  
  function updateNestedEditor(nested_editor) {
    var object_name   = _$.attr(nested_editor, 'name'),
        rows          = _$.find(nested_editor, '.nested-row'),
        visible_rows  = [],
        row;
    
    for(var i=0, ii=rows.length; i<ii; i++) {
      row = rows[i];
      renumberNestedRow(row, i);
      (getNestedRowFieldValue(row, '_destroy') != '1') && visible_rows.push(row);
    }
    
    var ii = visible_rows.length - 1;
    for(var i=0; i<ii; i++) { setAddNestedVisibility(visible_rows[i],  'hidden'); }
    if(ii >= 0)             { setAddNestedVisibility(visible_rows[ii], 'visible'); }
    
    observer.fire('after_reset_nested', nested_editor);
  }
  
  function renumberNestedRow(row, i) {
    withEach(_$.find(row, 'input, textarea, select'), function(e) {
      var name = _$.attr(e, 'name');
      if(name) {
        _$.attr(e, 'name', name.replace(/\[(\d+)\]/, function() { return '[' + i + ']'; }));
      }
    });
  }
  
  function setAddNestedVisibility(row, add_visibility) {
    var add_link = _$.find(row, '.add-link')[0];
    if(add_link) {
      if(add_visibility == 'visible') {
        _$.show(add_link);
      } else {
        _$.hide(add_link);
      }
    }
  }
  
  
  
  function resetNestedEditor(nested_editor) {
    var nested_rows = _$.find(nested_editor, '.nested-row');
    for(var i=1, ii=nested_rows.length; i<ii; i++) {
      var row = nested_rows[i];
      row.parentNode.removeChild(row);
    }
    updateNestedEditor(nested_editor);
  }
  
  
  
  
  
  function destroyRow(msg, id, path) {
    if(!msg || confirm(msg)) {
      renderDeleted(id);
      FT.xhr(path, 'delete');
      return true;
    }
    return false;
  }
  
  function renderDeleted(id) {
    var e = _$.find(id)[0];
    if(e) {
      _$.addClass(e, 'deleted');
      _$.removeClass(e, 'editable');
      _$.find(e, 'input').each(function(i) {
        i.disabled = true;
      });
    }
  }
  
  
  
  
  
  var Helpers = {
    restripeRows: function() {
      var rows = _$.find('.row');
      for(var i=0, ii=rows.length, alt=false; i<ii; i++, alt=!alt) {
        (alt ? _$.addClass : _$.removeClass)(rows[i], 'alt');
      }
    },
    
    // !nb: should this be a FreightTrain concern?
    hoverRow: function(row) {
      if(!row) throw new Error('row must not be null');
      _$.on(row, 'mouseover', function() {
        observer.fire('hover', [row]);
        _$.addClass(row, 'hovered');
      });
      _$.on(row, 'mouseout', function() {
        _$.removeClass(row, 'hovered');
      });
    },
    
    editRowInline: function(row, url_root, editor_writer, before_edit, after_edit) {
      var id = _$.attr(row, 'id');
      var idn = id.match(/\d+/);
      var url = url_root + '/' + idn;
      new FT.InlineEditor(url, row, editor_writer, before_edit, after_edit);
    },
    
    editRow: function(row, url_root_or_fn) {
      var handler;
      if(typeof url_root_or_fn == 'function') {
        handler = url_root_or_fn;
      } else {
        handler = function(row) {
          var id = _$.attr(row, 'id');
          var idn = id.match(/\d+/);
          var url = url_root_or_fn + '/' + idn; // + "/edit"
          window.location = url;
        }
      }
      _$.on(row, 'click', function() { handler(row); });
    },
    
    createOptions: function(options, selectedItem) {
      var html = '';
      for(var i=0, ii=options.length; i<ii; i++) {
        var option = options[i],
            isArray = (option instanceof Array),
            name = isArray ? option[0] : option,
            value = isArray ? option[1] : option,
            selected = (value == selectedItem);
        html += '<option value="' + value + '"' + (selected ? 'selected="selected"' : '') + '>' + name + '</option>';
      }
      return html;
    },
    
    forEachRow: function(row, editor, selector, fn) {
      var nested_rows     = _$.find(row, selector),
          nested_editors  = _$.find(editor, selector);
      for(var i=0, ii=nested_rows.length; i<ii; i++) {
        var nested_row    = nested_rows[i],
            nested_editor = nested_editors[i],
            name          = _$.attr(nested_editor, 'name');
        fn(nested_row, nested_editor, name);
      }
    },
    
    forEachNestedRow: function(root_tr, selector, fn) {
      var nested_rows = _$.find(root_tr, selector);
      for(var i=0, ii=nested_rows.length; i<ii; i++) {
        fn(nested_rows[i], i);
      }
    },
    
    createEditor: function(node_type, html, klass) {
      var editor = document.createElement(node_type);
      editor.className = 'row editor ' + klass;
      editor.innerHTML = html;
      return editor;
    },
    
    resetOnCreate: function(model_name, options) {
      options = options || 'all';
      if(options != 'none') {
        _$.on(document.body, 'ft:create', function(e) {
          withEach(_$.find('form[data-model="' + model_name + '"] #add_row'), function(row) {
            resetFormFieldsIn(row, options);
            selectFirstFieldIn(row);
          });
        });
      }
    }
  }
  
  
  
  
  
  function xhr(url, method, params, args) {
    params = params || {};
    params['freight_train'] = 'true';
    
    var csrf_param = getMetaValue('csrf-param');
    csrf_param && (params[csrf_param] = getMetaValue('csrf-token'));
    
    return _$.xhr(url, method, params, args);
  }
  
  function getMetaValue(name) {
    var meta_tag = _$.find('meta[name="' + name + '"]')[0];
    return meta_tag && _$.attr(meta_tag, 'content');
  }
  
  
  
  
  
  function copyValue(row, editor, attr_name) {
    var value    = getAttrValue(row, attr_name),
        controls = getFields(editor, attr_name);
    controls && value && _$.assign(controls, value);
    _$.fire(controls, 'ft:value_assigned');
  }
  
  function getAttrName(row, method) {
    return _$.attr(row, 'name') + '[' + method + ']';
  }
  
  function getAttrValue(row, attr_name) {
    var element = getField(row, attr_name);
    return element && (_$.attr(element, 'value') || _$.text(element));
  }
  
  function getAttrHtml(row, attr_name) {
    var element = getField(row, attr_name);
    return element && (_$.attr(element, 'value') || element.innerHTML);
  }
  
  function getField(row, attr_name) {
    var selector = '*[attr="' + attr_name + '"]',
        element  = _$.find(row, selector)[0];
    return element ? element : (FT.debug(selector + ' not found') && null);
  }
  
  function getFields(row, attr_name) {
    var selector = '*[attr="' + attr_name + '"]';
    return _$.find(row, selector);
  }
  
  
  
  function resetFormFieldsIn(parent, options) {
    var inputs          = _$.find(parent, 'input[type="text"], input[type="tel"], input[type="email"], textarea'),
        selects         = _$.find(parent, 'select'),
        nested_editors  = _$.find(parent, '.nested.editor');
        options         = options || {};
    
    function fieldToBeReset(id) {
      return !(options.only && !member(options.only, id)) &&
             !(options.except && member(options.except, id));
    }
    
    for(var i=0, ii=inputs.length; i<ii; i++) {
      var input = inputs[i];
      fieldToBeReset(input.id) && (input.value = '');
    }
    for(var i=0, ii=selects.length; i<ii; i++) {
      var select = selects[i];
      if(fieldToBeReset(select.id)) {
        select.selectedIndex = select.multiple ? -1 : 0;
        _$.fire(select,'change');
      }
    }
    for(var i=0, ii=nested_editors.length; i<ii; i++) {
      resetNestedEditor(nested_editors[i]);
    }
  }
  
  function selectFirstFieldIn(parent) {
    var inputs = _$.find(parent, 'input, select, textarea');
    for(var i=0, ii=inputs.length; i<ii; i++) {
      var input = inputs[i];
      if(_$.visible(input) && (input.type != 'hidden')) {
        _$.activate(input);
        return;
      }
    }
  }
  
  
  
  function withEach(array, fn) {
    for(var i=0, ii=array.length; i<ii; i++) { fn(array[i]); }
  }
  
  function member(array, item) {
    for(var i=0, ii=array.length; i<ii; i++) {
      if(array[i] == item) { return true; }
    }
    return false;
  }
  
  function extend(destination, source) {
    for(method in source) { destination[method] = source[method]; }
  }
  
  
  
  extend(FT, {
    Helpers:            Helpers,
    
    init:               init,
    
    adapter:            function() { return _$; },
    observe:            function(name, func) { observer.observe(name, func); },
    unobserve:          function(name, func) { observer.unobserve(name, func); },
    destroy:            destroyRow,
    xhr:                xhr,
    
    copyValue:          copyValue,
    getAttrName:        getAttrName,
    getAttrValue:       getAttrValue,
    getAttrHtml:        getAttrHtml,
    getField:           getField,
    
    resetFormFieldsIn:  resetFormFieldsIn,
    selectFirstFieldIn: selectFirstFieldIn,
    
    enableNestedEditors:    enableNestedEditors,
    enableNestedEditorsIn:  enableNestedEditorsIn,
    updateNestedEditors:    updateNestedEditors,
    updateNestedEditorsIn:  updateNestedEditorsIn,
    
    addNestedRow:           addNestedRow,
    deleteNestedRow:        deleteNestedRow,
    getNestedRowFromEvent:  getNestedRowFromEvent,
    
    
    
    /* ARE THESE NEXT TWO STRICTLY FREIGHT TRAIN? */
    check_selected_values: function(tr,tr_edit,attr_name) {
      var e=tr.down('*[attr="'+attr_name+'"]');
      if(e) {
        var values=e.readAttribute('value').split('|');
        for(var i=0; i<values.length; i++) {
          e=tr_edit.down('*[value="'+values[i]+'"]');
          if(!e) FT.debug('"'+values[i]+'" not found');
          else e.writeAttribute('checked','checked');
        }
      }
      else {
        FT.debug(attr_name+' not found');
      }
    },
    
    debug: function(o) {
      if(window.console && window.console.log) {
        window.console.log(o);
      }
    }
  });
})();
