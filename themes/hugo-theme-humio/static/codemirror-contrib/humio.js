var functionStart = {regex: /(\$?[^\{\}\(\)\s,.><\/\|]+?\()/,
 token: ["def"],
 push: "argumentList"};

var pipelineStart = {regex: /(\{)/, token: "def", push: "start", indent: true };
var pipelineEnd = {regex: /\}/, token: "def", pop: true, dedent: true };

CodeMirror.defineSimpleMode("humio", {
  // The start state contains the rules that are intially used
  start: [
    // FUNCTTION
    functionStart,

    // A next property will cause the mode to move to a different state
    {regex: /\/\*/, token: "comment", push: "comment"},
    {regex: /\/\/.*/, token: "comment"},

    // FIELD MATCHER - REGEX LITERAL
    {regex: /(\"(?:[^"\\]|\\.)*\"|[^\s!=><\|]+)(\s*)(=~)(\s*)(\/)/,
     token: ["variable-2", null, "operator", null, "variable-3"], push: "regex"},

    // LITERAL REGEX
    {regex: /\//, token: "variable-3", push: "regex" },

    { regex: /\(/, token: "def", push: "start", indent: true, },
    { regex: /\)/, token: "def", pop: true, dedent: true },

    pipelineStart,
    pipelineEnd,

    // FIELD MATCHER - STRING
    {regex: /(\"(?:[^"\\]|\\.)*\"|[^\s!=><\|]+)(\s*)(=|!=|>=?|<=?|:=|=~)(\s*)(\"(?:[^"\\]|\\.)*\"|[^\s\|\)]+)/,
     token: ["variable-2", null, "operator", null, "string"]},

    {regex: /"(?:[^\\]|\\.)*?(?:"|$)/, token: "string"},

    {regex: /\s(?:or|and|not)\s/i, token: "keyword"},

    {regex: /[!|]/, token: "operator"},

    {regex: /./, token: "string" }
  ],
  // The multi-line comment state.
  comment: [
    {regex: /.*?\*\//, token: "comment", pop: true},
    {regex: /.*/, token: "comment"}
  ],

  regex: [
    { regex: /\\./, token: "variable-5" },
    { regex: /\/[mdi]*/, token: "variable-3", pop: true },
    { regex: /(\(\?<)(.+?)(>)/, token: ["variable-3", "variable-4", "variable-3"]},
    { regex: /./, token: "variable-3" },
  ],

  argumentList: [
    // kv argument
    { regex: /\s*\)/, token: "def", pop: true },
    { regex: /(\S+?)(\s*)(=)(\s*)/,
     token: ["variable-2", null, "operator", null],
     next: "argumentValue"
    },

    // Unnamed Argument
    { next: "argumentValue" }
  ],

  argumentValue: [
    functionStart,

    pipelineStart,

    // ARRAY
    { regex: /\[.*?\]/, token: 'string', next: "moreArguments"},

    // STRING
    { regex: /(\"(?:[^"\\]|\\.)*\")|[^,\)]+/, token: "string", next: "moreArguments" },
  ],

  moreArguments: [
    { regex: /\s*?,\s*/, token: "operator", next: 'argumentList' },
    { regex: /\s*\)/, token: 'def', pop: true }
  ],

  // The meta property contains global information about the mode. It
  // can contain properties like lineComment, which are supported by
  // all modes, and also directives like dontIndentStates, which are
  // specific to simple modes.
  meta: {
    dontIndentStates: ["comment"],
    lineComment: "//"
  }
});

CodeMirror.defineMIME("text/x-humbug", "humbug");
