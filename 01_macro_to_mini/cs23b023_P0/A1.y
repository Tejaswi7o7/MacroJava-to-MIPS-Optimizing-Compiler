%{
#include <bits/stdc++.h>
using namespace std;

int yylex(void);
void yyerror(const char*){}
struct Macro{
	string name;
	vector<string>params;
	string body;
	bool expr;
};
string trim(const string& s) {
	size_t l=s.find_first_not_of(" \t\r\n");
	if(l==string::npos){return "";}
	return s.substr(l,s.find_last_not_of(" \t\r\n")-l+1);
}
size_t skip(const string& s,size_t p){
	while(p<s.size()&&isspace((unsigned char)s[p]))p++;
	return p;
}
bool idc(char c){return isalnum((unsigned char)c)||c=='_';}
bool ids(char c){return isalpha((unsigned char)c)||c=='_';}

bool is_valid_id(const string& s) {
	if(s.empty()||!ids(s[0]))return false;
	for(int i=1;i<(int)s.size();i++)
		if(!idc(s[i]))return false;
	return true;
}
size_t find_match(const string& s,size_t p,char open,char close){
	if(p>=s.size()||s[p]!=open)return string::npos;
	int d=1;
	for(size_t i=p+1;i<s.size();i++){
		if(s[i]==open)d++;
		else if(s[i]==close){d--;if(d==0)return i;}
	}
	return string::npos;
}
vector<string>split_args(const string& s){
	vector<string>res;
	string cur;
	int p1 =0,p2=0, p3= 0;  
	for(char c:s){
		if(c=='(') p1++;
		else if(c==')') p1--;
		else if(c=='[') p2++;
		else if(c==']') p2--;
		else if(c=='{') p3++;
		else if(c=='}') p3--;
		if(c==','&&p1==0&&p2==0&&p3==0){
			res.push_back(trim(cur));
			cur.clear();
		}else cur += c;
	}
	if(!trim(cur).empty()||!s.empty()) res.push_back(trim(cur));
	return res;
}
string remove_comments(const string& s,bool& ok){
	string res;
	for (size_t i=0;i<s.size();){
		if(s[i]=='/'&&i+1< s.size()&&s[i+1]=='/'){
			i+=2;
			while(i<s.size()&&s[i]!='\n')i++;
			if(i<s.size())res+='\n';
			continue;
		}
		
		if(s[i]=='/'&&i+1<s.size()&&s[i+1]=='*'){
			i+=2;
			bool found=false;
			while(i+1<s.size()) {
				if(s[i]=='*'&&s[i+1]=='/'){i+=2;found=true;break;}
				if(s[i]=='\n')res+='\n';
				i++;
			}
			if(!found){ok=false;return "";}
			res+=' ';
			continue;
		}
		res+=s[i++];
	}
	return res;
}

bool parse_macros(string& code,vector<Macro>& macros) {
	size_t p=0;
	while(true){
		p=skip(code,p);
		if(p>=code.size()||code.compare(p,7,"#define")!=0)break;

		size_t q=p+7;
		bool is_expr=false,is_stmt=false;
		if(code.compare(q, 4,"Expr")==0)is_expr=true;
		else if(code.compare(q,4,"Stmt")==0)is_stmt=true;
		else return false;
		q+=4;

		int arity=-1;
		if(q<code.size()&&isdigit((unsigned char)code[q])){
			arity=0;
			while(q<code.size()&&isdigit((unsigned char)code[q])){
				arity=arity*10 +(code[q]-'0');
				q++;
			}
			if(arity>2) return false;
		}
		q = skip(code, q);
		if (q >= code.size() || !ids(code[q])) return false;		
		size_t ne = q + 1;
		while (ne < code.size() && idc(code[ne])) ne++;
		string mname = code.substr(q, ne - q);

		for (auto& m : macros)
			if (m.name == mname) return false;
		q = skip(code, ne);
		if (q >= code.size() || code[q] != '(') return false;
		size_t pe = find_match(code, q, '(', ')');
		if (pe == string::npos) return false;

		vector<string> params = split_args(code.substr(q+1, pe-q-1));
		if (params.size() == 1 && params[0].empty()) params.clear();
		for (auto& x : params) if (!is_valid_id(x)) return false;
		if (arity >= 0) {
			if ((int)params.size() != arity) return false;
		} else {
			if (params.size() < 3) return false;
		}
		q = skip(code, pe + 1);
		char op = is_expr ? '(' : '{';
		char cl = is_expr ? ')' : '}';
		if (q >= code.size() || code[q] != op) return false;
		size_t be = find_match(code, q, op, cl);
		if (be == string::npos) return false;

		macros.push_back({mname, params, code.substr(q, be-q+1), is_expr});
		p = be + 1;
	}
	code.erase(0, p);
	return true;
}

string do_substitute(const string& body, const vector<string>& params,
					 const vector<string>& args) {
	unordered_map<string,string> mp;
	for (int i = 0; i < (int)params.size(); i++) mp[params[i]] = args[i];
	string res;
	for (size_t i = 0; i < body.size();) {
		if (ids(body[i])) {
			size_t j = i + 1;
			while (j < body.size() && idc(body[j])) j++;
			string tok = body.substr(i, j-i);
			auto it = mp.find(tok);
			if (it != mp.end()) res += "(" + it->second + ")";
			else res += tok;
			i = j;
		} else res += body[i++];
	}
	return res;
}

bool expand(string& code, const vector<Macro>& macros) {
	for (int iter = 0; iter < 10000; iter++) {
		bool changed = false;
		for (auto& m : macros) {
			size_t p = 0;
			while ((p = code.find(m.name, p)) != string::npos) {
				if (p > 0 && idc(code[p-1])) { p += m.name.size(); continue; }
				size_t after = p + m.name.size();
				if (after < code.size() && idc(code[after])) { p = after; continue; }
				size_t open = skip(code, after);
				if (open >= code.size() || code[open] != '(') { p = after; continue; }

				size_t close = find_match(code, open, '(', ')');
				if (close == string::npos) return false;
				vector<string> args = split_args(code.substr(open+1, close-open-1));
				if (args.size() == 1 && args[0].empty()) args.clear();
				if (args.size() != m.params.size()) return false;

				string repl = do_substitute(m.body, m.params, args);
				size_t end = close + 1;
				if (!m.expr) {
					end = skip(code, end);
					if (end >= code.size() || code[end] != ';') return false;
					end++;
				}
				code.replace(p, end - p, repl);
				changed = true;
				p += repl.size();
			}
		}
		if (!changed) return true;
	}
	return false;
}

struct Token { string s; };
vector<Token> tokens;
int pos;
bool take(const string& s) {
	if (pos < (int)tokens.size() && tokens[pos].s == s) { pos++; return true; }
	return false;
}
bool peek(const string& s) {
	return pos < (int)tokens.size() && tokens[pos].s == s;
}
bool get_id(string& out) {
	if (pos < (int)tokens.size() && is_valid_id(tokens[pos].s)) {
		out = tokens[pos++].s; return true;
	}
	return false;
}
bool do_tokenize(const string& s) {
	tokens.clear(); pos = 0;
	for (size_t i = 0; i < s.size();) {
		if (isspace((unsigned char)s[i])) { i++; continue; }

		if (ids(s[i])) {
			size_t j = i+1;
			while (j < s.size() && idc(s[j])) j++;
			tokens.push_back({s.substr(i, j-i)});
			i = j; continue;
		}
		if (isdigit((unsigned char)s[i])) {
			size_t j = i+1;
			while (j < s.size() && isdigit((unsigned char)s[j])) j++;
			tokens.push_back({s.substr(i, j)});
			i = j; continue;
		}
		if (i+1 < s.size()) {
			string tw = s.substr(i, 2);
			if (tw == "&&" || tw == "||" || tw == "!= " || tw == "<=") {
				tokens.push_back({tw}); i += 2; continue;
			}
			if (tw == "!=") {
				tokens.push_back({tw}); i += 2; continue;
			}
		}
		string singles = "{}[]();, .+-*/!<>=";
		if (singles.find(s[i]) != string::npos && s[i] != ' ') {
			tokens.push_back({string(1, s[i])}); i++; continue;
		}
		return false;  
	}
	return true;
}

bool parse_expr();
bool parse_stmt();
bool parse_type();

bool parse_primary() {
	if (pos >= (int)tokens.size()) return false;
	if (peek("true") || peek("false") || peek("this")) { pos++; return true; }
	if (isdigit((unsigned char)tokens[pos].s[0])) { pos++; return true; }
	if (take("(")) return parse_expr() && take(")");
	if (take("!")) return parse_expr();
	if (take("new")) {
		if (take("int")) return take("[") && parse_expr() && take("]");
		string nm;
		return get_id(nm) && take("(") && take(")");
	}
	string id;
	return get_id(id);
}
bool parse_expr() {
	if (!parse_primary()) return false;
	if (take("&&") || take("||") || take("!=") || take("<=") ||
		take("+") || take("-") || take("*") || take("/"))
		return parse_primary();
	if (take("[")) return parse_expr() && take("]");
	if (take(".")) {
		if (take("length")) return true;
		string id;
		if (!get_id(id) || !take("(")) return false;
		if (!peek(")")) {
			if (!parse_expr()) return false;
			while (take(",")) if (!parse_expr()) return false;
		}
		return take(")");
	}
	return true;
}
bool parse_type() {
	if (take("int")) {
		if (take("[")) return take("]");
		return true;
	}
	if (take("boolean")) return true;
	string id;
	return get_id(id);
}
bool parse_stmt() {
	if (take("{")) {
		while (!peek("}") && pos < (int)tokens.size())
			if (!parse_stmt()) return false;
		return take("}");
	}
	if (take("System"))
		return take(".") && take("out") && take(".") && take("println")
			&& take("(") && parse_expr() && take(")") && take(";");
	if (take("if")) {
		if (!take("(") || !parse_expr() || !take(")") || !parse_stmt()) return false;
		if (take("else")) return parse_stmt();
		return true;
	}
	if (take("while"))
		return take("(") && parse_expr() && take(")") && parse_stmt();
	string id;
	if (!get_id(id)) return false;
	if (take("["))
		return parse_expr() && take("]") && take("=") && parse_expr() && take(";");
	if (take("="))
		return parse_expr() && take(";");
	if (take("(")) {
		if (!peek(")")) {
			if (!parse_expr()) return false;
			while (take(",")) if (!parse_expr()) return false;
		}
		return take(")") && take(";");
	}
	return false;
}
bool parse_main_class() {
	string cls, arg;
	return take("class") && get_id(cls) && take("{") &&
		   take("public") && take("static") && take("void") && take("main") &&
		   take("(") && take("String") && take("[") && take("]") &&
		   get_id(arg) && take(")") && take("{") &&
		   take("System") && take(".") && take("out") && take(".") &&
		   take("println") && take("(") && parse_expr() && take(")") && take(";") &&
		   take("}") && take("}");
}

bool parse_formals() {
	if (peek(")")) return true;
	if (!parse_type()) return false;
	string id;
	if (!get_id(id)) return false;
	while (take(",")) {
		if (!parse_type() || !get_id(id)) return false;
	}
	return true;
}

bool parse_method() {
	if (!take("public") || !parse_type()) return false;
	string id;
	if (!get_id(id) || !take("(") || !parse_formals() || !take(")") || !take("{"))
		return false;
	while (peek("int") || peek("boolean")) {
		if (!parse_type() || !get_id(id) || !take(";")) return false;
	}
	while (pos+1 < (int)tokens.size() && is_valid_id(tokens[pos].s)
		   && is_valid_id(tokens[pos+1].s)) {
		if (peek("if") || peek("while") || peek("return") || peek("System")) break;
		if (!parse_type() || !get_id(id) || !take(";")) return false;
	}
	while (!peek("return") && !peek("}") && pos < (int)tokens.size())
		if (!parse_stmt()) return false;
	return take("return") && parse_expr() && take(";") && take("}");
}

bool parse_class() {
	string cls, tmp;
	if (!take("class") || !get_id(cls)) return false;
	if (take("extends")) if (!get_id(tmp)) return false;
	if (!take("{")) return false;

	while (!peek("public") && !peek("}")) {
		int save = pos;
		if (!parse_type()) return false;
		if (!get_id(tmp)) return false;
		if (!take(";")) { pos = save; break; }
	}

	while (peek("public")) if (!parse_method()) return false;
	return take("}");
}

bool check_program(const string& code){
	if (!do_tokenize(code)) return false;
	if (!parse_main_class()) return false;
	while (pos < (int)tokens.size())
		if (!parse_class()) return false;
	return pos == (int)tokens.size();
}

%}

%token DUMMY

%%
program:
	;
%%

int main() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr);

	string input((istreambuf_iterator<char>(cin)),istreambuf_iterator<char>());

	bool ok=true;
	string code=remove_comments(input,ok);
	if (!ok){cout << "//Failed to parse input code\n"; return 0;}
	vector<Macro>macros;
	if(!parse_macros(code,macros)){
		cout<<"//Failed to parse input code\n"; return 0;
	}
	if(code.find('#')!=string::npos) {
		cout<<"//Failed to parse input code\n"; return 0;
	}
	if(!expand(code,macros)){
		cout<<"//Failed to parse input code\n"; return 0;
	}
	code= trim(code);
	if (code.empty()||!check_program(code)) {
		cout<<"//Failed to parse input code\n"; return 0;
	}
	cout << code << '\n';
	return 0;
}