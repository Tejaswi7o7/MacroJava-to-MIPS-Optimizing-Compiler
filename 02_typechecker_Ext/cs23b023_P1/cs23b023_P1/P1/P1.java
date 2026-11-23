import syntaxtree.*;
import visitor.*;
import java.util.*;

public class P1{
   public static void main(String[]args){
      try{
         Node root = new MiniJavaParser(System.in).Goal();
         GJDepthFirst<String,String>df=new GJDepthFirst<>();
         // Object value = root.accept(df, null); // Your assignment part is invoked here.
         df.pass=1;
         root.accept(df,"");
         df.checkCyclicInheritance();
         df.checkDuplicateDeclarations();
         df.checkMethodOverrides();
         df.pass=2;
         root.accept(df,"");
         System.out.println("Program type checked successfully");
      }
      catch (ParseException e) {
         System.out.println(e.toString());
      }
   }
}
