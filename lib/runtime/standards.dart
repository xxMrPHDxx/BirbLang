import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Birb/utils/ast/ast_types.dart';
import 'package:Birb/utils/exceptions.dart';
import 'package:http/http.dart';

import 'package:Birb/utils/AST.dart';
import 'package:Birb/parser/data_type.dart';
import 'package:Birb/lexer/lexer.dart';
import 'package:Birb/parser/parser.dart';
import 'package:Birb/runtime/runtime.dart';

AST INITIALIZED_NOOP;

void initStandards(Runtime runtime) async {
  registerGlobalVariable(runtime, 'birbVer', '0.0.1');
  registerGlobalFunction(runtime, 'screm', funcScrem);
  registerGlobalFunction(runtime, 'exit', funcExit);
  registerGlobalFunction(runtime, 'mock', funcMock);
  registerGlobalFunction(runtime, 'Date', funcDate);
  registerGlobalFunction(runtime, 'Time', funcTime);
  registerGlobalFunction(runtime, 'decodeJson', funcDecodeJson);
  registerGlobalFunction(runtime, 'encodeJson', funcEncodeJson);

  registerGlobalFutureFunction(runtime, 'grab', funcGrab);
  registerGlobalFutureFunction(runtime, 'GET', funcGet);
  registerGlobalFutureFunction(runtime, 'POST', funcPost);
}

Future<AST> funcGrab(Runtime runtime, AST self, List args) async {
  runtimeExpectArgs(args, [ASTType.AST_STRING]);

  AST astStr = args[0];
  String filename = astStr.stringValue;

  Lexer lexer = initLexer(File(filename).readAsStringSync());
  Parser parser = initParser(lexer);
  AST node = parse(parser);
  await visit(runtime, node);
  
  return AnyNode();
}

/// STDOUT
AST funcScrem(Runtime runtime, AST self, List args) {
  for (int i = 0; i < args.length; i++) {
    AST astArg = args[i];
    if (astArg.type == ASTType.AST_BINARYOP)
      visitBinaryOp(initRuntime(), astArg).then((value) => astArg = value);
    var str = astToString(astArg);

    if (str == null)
      throw UnexpectedTokenException('Screm must contain non-null arguments');

    print(str);
  }

  return INITIALIZED_NOOP;
}

/// STDIN
AST funcMock(Runtime runtime, AST self, List args) {
  var astString = StringNode();
  astString.stringValue =
      stdin.readLineSync(encoding: Encoding.getByName('utf-8')).trim();

  return astString;
}

/**
 * IO
 */
AST funcExit(Runtime runtime, AST self, List args) {
  runtimeExpectArgs(args, [ASTType.AST_INT]);

  AST exitAST = args[0];

  exit(exitAST.intVal);
  return null;
}

/**
 * DATE AND TIME
 */
AST funcDate(Runtime runtime, AST self, List args) {
  var astObj = ClassNode();
  astObj.variableType = TypeNode();
  astObj.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_CLASS);

  // ADD YEAR TO DATE OBJECT
  var astVarYear = VarDefNode();
  astVarYear.variableName = 'year';
  astVarYear.variableType = TypeNode();
  astVarYear.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  var astIntYear = IntNode();
  astIntYear.intVal = DateTime.now().year;
  astVarYear.variableValue = astIntYear;

  astObj.classChildren.add(astVarYear);

  // ADD MONTH TO DATE OBJECT
  var astVarMonth = VarDefNode();
  astVarMonth.variableName = 'month';
  astVarMonth.variableType = TypeNode();
  astVarMonth.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  var astIntMonth = IntNode();
  astIntMonth.intVal = DateTime.now().month;
  astVarMonth.variableValue = astIntMonth;

  astObj.classChildren.add(astVarMonth);

  // ADD DAYS TO DATE OBJECT
  var astVarDay = VarDefNode();
  astVarDay.variableName = 'day';
  astVarDay.variableType = TypeNode();
  astVarDay.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  var astIntDay = IntNode();
  astIntDay.intVal = DateTime.now().day;
  astVarDay.variableValue = astIntDay;

  astObj.classChildren.add(astVarDay);

  // ADD DAYS TO DATE OBJECT
  var astVarWeekDay = VarDefNode();
  astVarWeekDay.variableName = 'weekday';
  astVarWeekDay.variableType = TypeNode();
  astVarWeekDay.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  var astIntWeekDay = IntNode();
  astIntWeekDay.intVal = DateTime.now().weekday;
  astIntWeekDay.variableValue = astIntWeekDay;

  astObj.classChildren.add(astVarWeekDay);

  return astObj;
}

AST funcTime(Runtime runtime, AST self, List args) {
  var astObj = ClassNode();
  astObj.variableType = TypeNode();
  astObj.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_CLASS);

  // ADD HOURS TO TIME OBJECT
  var astVarHour = VarDefNode();
  astVarHour.variableName = 'hour';
  astVarHour.variableType = TypeNode();
  astVarHour.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  var astIntHour = IntNode();
  astIntHour.intVal = DateTime.now().hour;
  astVarHour.variableValue = astIntHour;

  astObj.classChildren.add(astVarHour);

  // ADD MINUTES TO TIME OBJECT
  var astVarMinute = VarDefNode();
  astVarMinute.variableName = 'minute';
  astVarMinute.variableType = TypeNode();
  astVarMinute.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  var astIntMinute = IntNode();
  astIntMinute.intVal = DateTime.now().minute;
  astVarHour.variableValue = astIntMinute;

  astObj.classChildren.add(astVarMinute);

  // ADD SECONDS TO TIME OBJECT
  var astVarSeconds = VarDefNode();
  astVarSeconds.variableName = 'second';
  astVarSeconds.variableType = TypeNode();
  astVarSeconds.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  var astIntSeconds = IntNode();
  astIntSeconds.intVal = DateTime.now().second;
  astVarSeconds.variableValue = astIntSeconds;

  astObj.classChildren.add(astVarSeconds);

  // ADD MILLISECONDS TO TIME OBJECT
  var astVarMilliSeconds = VarDefNode();
  astVarMilliSeconds.variableName = 'milliSecond';
  astVarMilliSeconds.variableType = TypeNode();
  astVarMilliSeconds.variableType.typeValue =
      initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  var astIntMilliSeconds = IntNode();
  astIntMilliSeconds.intVal = DateTime.now().millisecond;
  astVarMilliSeconds.variableValue = astIntMilliSeconds;

  astObj.classChildren.add(astVarMilliSeconds);

  return astObj;
}

/**
 * HTTP
 */
Future<AST> funcGet(Runtime runtime, AST self, List args) async {
  if (args.length == 3)
    runtimeExpectArgs(args,
        [ASTType.AST_STRING, ASTType.AST_MAP, ASTType.AST_FUNC_DEFINITION]);
  else
    runtimeExpectArgs(args, [ASTType.AST_STRING, ASTType.AST_MAP]);

  String url = (args[0] as AST).stringValue;
  Map headers = (args[1] as AST).map;
  AST funcDef;
  AST funCall;

  if (args.length == 3) {
    funcDef = args[2];
    AST funcCalExpr = VariableNode();
    funcCalExpr.variableName = funcDef.funcName;

    funCall = FuncCallNode();
    funCall.funcName = funcDef.funcName;
    funCall.type = ASTType.AST_FUNC_CALL;
    funCall.funcCallExpression = funcCalExpr;
  }

  Map<String, String> head = {};
  headers.forEach((key, value) => head[key] = (value as AST).stringValue);

  Response response = await get(url, headers: head);
  if (args.length == 3) await visitFuncCall(runtime, funCall);

  var astObj = ClassNode();
  astObj.variableType = TypeNode();
  astObj.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_CLASS);

  // BODY
  var ast = VarDefNode();
  ast.variableName = 'body';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_STRING);

  var astVal = StringNode();
  astVal.stringValue = response.body;
  ast.variableValue = astVal;

  astObj.classChildren.add(ast);

  // BODY BYTES
  ast = VarDefNode();
  ast.variableName = 'bodyBytes';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_LIST);

  var astListVal = ListNode();
  astListVal.listElements = response.bodyBytes;
  ast.variableValue = astListVal;

  astObj.classChildren.add(ast);

  // STATUS CODE
  ast = VarDefNode();
  ast.variableName = 'statusCode';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  var astIntVal = IntNode();
  astIntVal.intVal = response.statusCode;
  ast.variableValue = astIntVal;

  astObj.classChildren.add(ast);

  // CONTENT LENGTH
  ast = VarDefNode();
  ast.variableName = 'contentLength';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  astIntVal = IntNode();
  astIntVal.intVal = response.contentLength;
  ast.variableValue = astIntVal;

  astObj.classChildren.add(ast);

  // REASON PHRASE
  ast = VarDefNode();
  ast.variableName = 'reason';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_STRING);

  astVal = StringNode();
  astVal.stringValue = response.reasonPhrase;
  ast.variableValue = astVal;

  astObj.classChildren.add(ast);

  // HEADERS
  ast = VarDefNode();
  ast.variableName = 'headers';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_MAP);

  var astMapVal = MapNode();
  astMapVal.map = response.headers;
  ast.variableValue = astMapVal;

  astObj.classChildren.add(ast);

  return astObj;
}

Future<AST> funcPost(Runtime runtime, AST self, List args) async {
  if (args.length == 4)
    runtimeExpectArgs(args, [
      ASTType.AST_STRING,
      ASTType.AST_MAP,
      ASTType.AST_MAP,
      ASTType.AST_FUNC_DEFINITION
    ]);
  else
    runtimeExpectArgs(
        args, [ASTType.AST_STRING, ASTType.AST_MAP, ASTType.AST_MAP]);

  String url = (args[0] as AST).stringValue;
  Map bodyEarly = (args[1] as AST).map;
  Map head = (args[2] as AST).map;

  AST funcDef;
  AST funCall;

  if (args.length == 4) {
    funcDef = args[3];
    AST funcCalExpr = VariableNode();
    funcCalExpr.variableName = funcDef.funcName;

    funCall = FuncCallNode();
    funCall.funcName = funcDef.funcName;
    funCall.type = ASTType.AST_FUNC_CALL;
    funCall.funcCallExpression = funcCalExpr;
  }

  Map<String, String> body = {};
  bodyEarly.forEach((key, value) => body[key] = (value as AST).stringValue);

  Map<String, String> headers = {};
  head.forEach((key, value) => headers[key] = (value as AST).stringValue);

  Response response = await post(url, body: body, headers: headers);
  if (args.length == 4) await visitCompound(runtime, funCall);

  var astObj = ClassNode();
  astObj.variableType = TypeNode();
  astObj.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_CLASS);

  // BODY
  var ast = VarDefNode();
  ast.variableName = 'body';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_STRING);

  var astVal = StringNode();
  astVal.stringValue = response.body;
  ast.variableValue = astVal;

  astObj.classChildren.add(ast);

  // BODY BYTES
  ast = VarDefNode();
  ast.variableName = 'bodyBytes';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_LIST);

  var astListVal = ListNode();
  astListVal.listElements = response.bodyBytes;
  ast.variableValue = astListVal;

  astObj.classChildren.add(ast);

  // STATUS CODE
  ast = VarDefNode();
  ast.variableName = 'statusCode';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  var astIntVal = IntNode();
  astIntVal.intVal = response.statusCode;
  ast.variableValue = astIntVal;

  astObj.classChildren.add(ast);

  // CONTENT LENGTH
  ast = VarDefNode();
  ast.variableName = 'contentLength';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_INT);

  astIntVal = IntNode();
  astVal.intVal = response.contentLength;
  ast.variableValue = astVal;

  astObj.classChildren.add(ast);

  // REASON PHRASE
  ast = VarDefNode();
  ast.variableName = 'reason';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_STRING);

  astVal = StringNode();
  astVal.stringValue = response.reasonPhrase;
  ast.variableValue = astVal;

  astObj.classChildren.add(ast);

  // HEADERS
  ast = VarDefNode();
  ast.variableName = 'headers';
  ast.variableType = TypeNode();
  ast.variableType.typeValue = initDataTypeAs(DATATYPE.DATA_TYPE_MAP);

  var astMapVal = MapNode();
  astMapVal.map = response.headers;
  ast.variableValue = astMapVal;

  astObj.classChildren.add(ast);

  return astObj;
}

AST funcDecodeJson(Runtime runtime, AST self, List args) {
  runtimeExpectArgs(args, [ASTType.AST_STRING]);

  String jsonString = (args[0] as AST).stringValue;

  var decoded = jsonDecode(jsonString);
  AST jsonAST;
  if (decoded is List)
    jsonAST = ListNode()..listElements = decoded;
  else
    jsonAST = MapNode()
      ..map = jsonDecode(jsonString) as Map<String, dynamic>;

  return jsonAST;
}

AST funcEncodeJson(Runtime runtime, AST self, List args) {
  runtimeExpectArgs(args, [ASTType.AST_MAP]);

  Map map = (args[0] as AST).map;

  Map jsonMap = {};

  map.forEach((key, value) {
    AST val = value;
    switch (val.type) {
      case ASTType.AST_STRING:
        jsonMap[key] = val.stringValue;
        break;
      case ASTType.AST_INT:
        jsonMap[key] = val.intVal;
        break;
      case ASTType.AST_DOUBLE:
        jsonMap[key] = val.doubleVal;
        break;
      case ASTType.AST_LIST:
        jsonMap[key] = val.listElements;
        break;
      case ASTType.AST_MAP:
        jsonMap[key] = val.map;
        break;
      default:
        throw JsonValueTypeException(key, val.type);
    }
    return;
  });

  AST jsonAST = StringNode()..stringValue = jsonEncode(jsonMap);

  return jsonAST;
}
