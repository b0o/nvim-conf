(let_binding
  ((value_identifier) @name)
  (function) @type) @start

(let_binding
  ((value_identifier) @name)
  (type_annotation
    (function_type)) @type) @start

(module_declaration
  name: (module_identifier) @name) @type

(type_declaration
  ((type_identifier) @name)) @type

(external_declaration
  ((value_identifier) @name)) @type
