//
//  GrammaticalClass.swift
//  GrammaticalAnalysis
//
//  Created by 吴子鸿 on 16/9/27.
//  Copyright © 2016年 吴子鸿. All rights reserved.
//

import Foundation
struct GrammarStruct {
    var isused:Bool=false       //去掉无效规则后当前文法是是否起到作用
    var leftS:String=""     //产生式左部
    var rightS:[String]=[]      //产生式左部的右部的集合
    var firstSet:[String]=[]    //leftS的first集
    var followSet:[String]=[]   //leftS的follow集
}

class GrammaticalClass {
    var GramList:[GrammarStruct]=[]   //文法
    var NoSymbol:[String:Int]=[:]     //非终结符的集合   哪个字母，第几个出现
    var EndSymbol:[String]=[]
    var StartSymbol:String=""
    
    var returnStr=""
    
    var AnalysisTable:[String:[(String,String)]]=[:]      // [非终结符:(终结符,转移的式子)]
    
    init(gram:[GrammarStruct],s:String){
        self.GramList=gram
        self.StartSymbol=s
    }
    func EliminatingLeftRecursion(){        //消除左递归
        //建立非终结符的集合
        var k=0;
        for grammar in GramList
        {
            if NoSymbol[grammar.leftS] == nil
            {
                NoSymbol[grammar.leftS]=k
                k=k+1
            }
        }
        //消除间接左递归
        for i in 0..<GramList.count
        {
            for j in 0..<i
            {
                let nowch=GramList[j].leftS    //Aj
                var now:[String]=[]     //新产生的GramList[i].rightS数组
                for k in 0..<GramList[i].rightS.count
                {
                    if String(GramList[i].rightS[k][GramList[i].rightS[k].startIndex.advancedBy(0)]) == nowch       //把形如Ai→Ajγ的产生式改写成Ai→δ1γ /δ2γ /…/δkγ 其中Aj→δ1 /δ2 /…/δk是关于的Aj全部规则；
                    {
                        for l in 0..<GramList[j].rightS.count
                        {
                            var s=""
                            s=GramList[i].rightS[k]
                            s.removeAtIndex(s.startIndex)
                            s=GramList[j].rightS[l]+s
                            now.append(s)
                        }
                    }
                }
                for k in 0..<GramList[i].rightS.count
                {
                    
                    if String(GramList[i].rightS[k][GramList[i].rightS[k].startIndex.advancedBy(0)]) != nowch       //把没有Ai→Ajγ的规则的Ai->???式子加进来
                    {
                        now.append(GramList[i].rightS[k])
                    }
                    
                }
                GramList[i].rightS=now
            }
        }
        
        returnStr+="消除间接左递归结果：\n"
        for grammar in GramList
        {
            var s:String=""
            s=grammar.leftS+"->"
            s=s+grammar.rightS[0]
            for j in 1..<grammar.rightS.count
            {
                s=s+"|"+grammar.rightS[j]
            }
            returnStr+=s+"\n"
        }
        
        
        //消除直接左递归
        var GramListCopy=GramList
        for gr in 0..<GramList.count
        {
            var grammar=GramList[gr]
            for ri in 0..<grammar.rightS.count
            {
                let right=grammar.rightS[ri]    //产生式右部
                if (String(right[right.startIndex.advancedBy(0)]) == grammar.leftS)
                {
                    var new=GrammarStruct()      //产生的S'
                    var change=GrammarStruct()   //改变后的S
                    change.leftS=grammar.leftS
                    change.rightS=[]
                    new.leftS=grammar.leftS+"'"
                    new.rightS=[]
                    for i in 0..<grammar.rightS.count
                    {
                        if String(grammar.rightS[i][grammar.rightS[i].startIndex.advancedBy(0)]) == grammar.leftS   //形如 S->Sabc这样的式子，产生了左递归 替换为 S'->abcS'
                        {
                            var s:String=""
                            s=grammar.rightS[i]
                            s.removeAtIndex(s.startIndex)
                            s=s+new.leftS   //abc=abc+"S'"
                            new.rightS.append(s)
                        }
                        else    //形如 S->abc这样的式子，替换为S->abcS'
                        {
                            var s:String=""
                            s=grammar.rightS[i]
                            s=s+new.leftS   //abc=abc+"S'"
                            change.rightS.append(s)
                        }
                    }
                    GramListCopy[gr]=change
                    new.rightS.append("ε")
                    GramListCopy.append(new)
                    break
                }
            }
        }
        GramList=GramListCopy
        
        returnStr+="消除间接左递归结果：\n"
        for grammar in GramList
        {
            var s:String=""
            s=grammar.leftS+"->"
            s=s+grammar.rightS[0]
            for j in 1..<grammar.rightS.count
            {
                s=s+"|"+grammar.rightS[j]
            }
            returnStr+=s+"\n"
        }
        
        //化简式子，去掉无效规则
        for i in 0..<GramList.count
        {
            if GramList[i].leftS == StartSymbol //文法G(S)从S开始 开始文法
            {
                search(i)   //从当前文法开始找，有用的isused标记为1
            }
        }
        GramListCopy=[]
        for i in 0..<GramList.count
        {
            if GramList[i].isused
            {
                GramListCopy.append(GramList[i])
            }
        }
        GramList=GramListCopy
        NoSymbol=[:]
        returnStr+="最终消除左递归结果：\n"
        for grammar in GramList
        {
            NoSymbol[grammar.leftS]=1   //标记存在
            
            var s:String=""
            s=grammar.leftS+"->"
            s=s+grammar.rightS[0]
            for j in 1..<grammar.rightS.count
            {
                s=s+"|"+grammar.rightS[j]
            }
            returnStr+=s+"\n"
        }
        
    }
    
    func search(from:Int)       //递归搜寻有效的文法规则
    {
        if GramList[from].isused == true
            { return }
        GramList[from].isused=true
        for i in 0..<GramList[from].rightS.count
        {
            let right=GramList[from].rightS[i]
            for j in 0..<right.characters.count
            {
                if j<right.characters.count-1   //后面可能有"'"
                {
                    if right[right.startIndex.advancedBy(j+1)] == "'"       //带'的符号
                    {
                        let s=String(right[right.startIndex.advancedBy(j)])+String(right[right.startIndex.advancedBy(j+1)])     // right[j]+"'"
                        for l in 0..<GramList.count
                        {
                            if GramList[l].leftS == s
                            {
                                search(l)
                            }
                        }
                        continue
                        
                    }
                }
                //不满足 right[j]+"'"的形式，则进行下面运算
                let s=String(right[right.startIndex.advancedBy(j)])
                for l in 0..<GramList.count
                {
                    if GramList[l].leftS == s
                    {
                        search(l)
                    }
                }
                
            }
        }
        
    }
    
    func CalFirstSet()  {       //求first集
        for gr in 0..<GramList.count
        {
            let grammar=GramList[gr]
            for right in grammar.rightS
            {
                var hasnil=true
                for i in 0..<right.characters.count
                {
                    if hasnil == false      //当前寻找的没找到空字，则停止寻找
                    {
                        break
                    }
                    hasnil=false
                    if right[right.startIndex.advancedBy(i)] == "'" //当前字符是"'"，和上一个连着，找下一个去
                    {
                        continue
                    }
                    var s:String    //要找的下一个符号
                    if i<right.characters.count-1
                    {
                        if right[right.startIndex.advancedBy(i+1)] == "'"       //带'的符号
                        {
                            s=String(right[right.startIndex.advancedBy(i)])+String(right[right.startIndex.advancedBy(i+1)])     // right[i]+"'"
                        }
                        else
                        {
                            s=String(right[right.startIndex.advancedBy(i)])     // right[i]
                        }
                    }
                    else
                    {
                        s=String(right[right.startIndex.advancedBy(i)])
                    }
                    if (NoSymbol[s] != nil)     //该符号为非终结符
                    {
                        var followSet:[String]=[]
                        getFirstSet(&followSet, s: s, hasnil: &hasnil)  //递归查找
                        for k in 0..<followSet.count
                        {
                            if GramList[gr].firstSet.indexOf(followSet[k]) == nil
                            {
                                GramList[gr].firstSet.append(followSet[k])
                            }
                        }
                    }
                    else        //该符号为终结符，不用找了
                    {
                        if GramList[gr].firstSet.indexOf(s) == nil
                        {
                            GramList[gr].firstSet.append(s)
                            break
                        }
                    }
                }
            }
        }
        
        returnStr+="最终First集结果：\n"
        for grammar in GramList
        {
            NoSymbol[grammar.leftS]=1   //标记存在
            
            var s:String=""
            s=grammar.leftS+"->"
            s=s+grammar.firstSet[0]
            for j in 1..<grammar.firstSet.count
            {
                s=s+"|"+grammar.firstSet[j]
            }
            returnStr+=s+"\n"
        }

    }
    
    func getFirstSet(inout firstSet:[String],s:String,inout hasnil:Bool)     //查找非终结符 s 的first集
    {
        for gr in 0..<GramList.count
        {
            if GramList[gr].leftS == s
            {
                if GramList[gr].firstSet.count>0   //已经计算过了它的first集
                {
                    for i in GramList[gr].firstSet
                    {
                        if firstSet.indexOf(i) == nil
                        {
                            if (i == "ε")
                            {
                                hasnil=true
                            }
                            firstSet.append(i)
                        }
                    }
                }
                else
                {
                    for right in GramList[gr].rightS
                    {
                        var diguihasnil=true
                        for i in 0..<right.characters.count
                        {
                            if diguihasnil == false      //当前寻找的没找到空字，则停止寻找
                            {
                                break
                            }
                            if i>0
                            {
                                hasnil=true
                            }
                            diguihasnil=false
                            if right[right.startIndex.advancedBy(i)] == "'" //当前字符是"'"，和上一个连着，找下一个去
                            {
                                continue
                            }
                            var s:String    //要找的下一个符号
                            if i<right.characters.count-1
                            {
                                if right[right.startIndex.advancedBy(i+1)] == "'"       //带'的符号
                                {
                                    s=String(right[right.startIndex.advancedBy(i)])+String(right[right.startIndex.advancedBy(i+1)])     // right[i]+"'"
                                }
                                else
                                {
                                    s=String(right[right.startIndex.advancedBy(i)])     // right[i]
                                }
                            }
                            else
                            {
                                s=String(right[right.startIndex.advancedBy(i)])
                            }
                            if (NoSymbol[s] != nil)     //该符号为非终结符
                            {
                                var followSet:[String]=[]       //其实是 firstset，为区分
                                getFirstSet(&followSet, s: s, hasnil: &diguihasnil)  //递归查找
                                for k in 0..<followSet.count
                                {
                                    if GramList[gr].firstSet.indexOf(followSet[k]) == nil   //添加到当前的
                                    {
                                        GramList[gr].firstSet.append(followSet[k])
                                    }
                                    if firstSet.indexOf(followSet[k]) == nil        //添加到总的
                                    {
                                        firstSet.append(followSet[k])
                                    }
                                    if (s == "ε")       //判断空
                                    {
                                        hasnil=true
                                    }
                                    
                                }
                            }
                            else        //该符号为终结符，不用找了
                            {
                                if GramList[gr].firstSet.indexOf(s) == nil
                                {
                                    if GramList[gr].firstSet.indexOf(s) == nil   //添加到当前的
                                    {
                                        GramList[gr].firstSet.append(s)
                                    }
                                    if firstSet.indexOf(s) == nil        //添加到总的
                                    {
                                        firstSet.append(s)
                                    }
                                    if (s == "ε")       //判断空
                                    {
                                        hasnil=true
                                    }
                                    break
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
        
    }
    
    func CalFollowSet()  {
        for i in 0..<GramList.count //当前要求的leftS
        {
            if GramList[i].leftS == StartSymbol     //是开始文法s，加入＃
            {
                if GramList[i].followSet.indexOf("#") == nil
                {
                    GramList[i].followSet.append("#")
                }
            }
            for j in 0..<GramList.count //查找的grammar
            {
                for k in 0..<GramList[j].rightS.count   //查找的grammar的右部
                {
                    if GramList[i].leftS.characters.count==1    //单个字母
                    {
                        for pp in 0..<GramList[j].rightS[k].characters.count
                        {
                            var s=pp
                            if (s<GramList[j].rightS[k].characters.count-1 && String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s)]) == GramList[i].leftS && String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+1)]) != "'") || (s == GramList[j].rightS[k].characters.count-1 && String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s)]) == GramList[i].leftS) //i左部有相等的右部
                            {
                                var hasnil=true
                                s=s-1
                                while hasnil == true
                                {
                                    s=s+1
                                    if s<=GramList[j].rightS[k].characters.count-1
                                    {
                                        if (GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s)]) == "'"
                                        {
                                            continue
                                        }
                                    }
                                    hasnil=false
                                    var followSet:[String]=[]
                                    if s<GramList[j].rightS[k].characters.count-1   //右侧还有字母
                                    {
                                        var str=""
                                        if (s<GramList[j].rightS[k].characters.count-2 && GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+2)] == "'")   //右侧的有'
                                        {
                                            str=String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+1)])+String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+2)])
                                            s=s+1
                                            
                                        }
                                        else    //右侧为单个字符，判断是不是文法左部
                                        {
                                            str=String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+1)])
                                        }
                                        if NoSymbol[str] != nil
                                        {
                                            for t in 0..<GramList.count
                                            {
                                                if GramList[t].leftS == str
                                                {
                                                    for tt in GramList[t].firstSet
                                                    {
                                                        if tt != "ε"
                                                        {
                                                            if GramList[i].followSet.indexOf(tt) == nil
                                                            {
                                                                GramList[i].followSet.append(tt)
                                                            }
                                                        }
                                                        else
                                                        {
                                                            hasnil=true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            if GramList[i].followSet.indexOf(str) == nil
                                            {
                                                GramList[i].followSet.append(str)
                                            }
                                        }
                                    }
                                    else    //右侧没有字母了
                                    {
                                        let follow=GramList[j].followSet
                                        if follow.count>0
                                        {
                                            for k in follow
                                            {
                                                if GramList[i].followSet.indexOf(k) == nil
                                                {
                                                    GramList[i].followSet.append(k)
                                                }
                                            }
                                        }
                                        else    //又要求左边这个的follow...无穷无尽啊！！
                                        {
                                            if GramList[i].leftS != GramList[j].leftS
                                            {
                                                GetFollowSet(&followSet, SearchS: GramList[j].leftS, Shasnil: &hasnil)
                                                for k in followSet
                                                {
                                                    if GramList[j].followSet.indexOf(k) == nil
                                                    {
                                                        GramList[j].followSet.append(k)
                                                    }
                                                    if GramList[i].followSet.indexOf(k) == nil
                                                    {
                                                        GramList[i].followSet.append(k)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else        //俩字母，带'
                    {
                        for pp in 0..<GramList[j].rightS[k].characters.count
                        {
                            var s=pp
                            if (s==GramList[j].rightS[k].characters.count-1)
                                {break}
                            if String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s)])+String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+1)]) == GramList[i].leftS   //i左部有相等的右部
                            {
                                var hasnil=true
                                s=s-1
                                while hasnil==true
                                {
                                    s=s+1
                                    if s<=GramList[j].rightS[k].characters.count-1
                                    {
                                        if (GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s)]) == "'"
                                        {
                                            continue
                                        }
                                    }
                                    hasnil=false
                                    var followSet:[String]=[]
                                    if s<GramList[j].rightS[k].characters.count-2   //右侧还有字母
                                    {
                                        var str=""
                                        if (s<GramList[j].rightS[k].characters.count-3 && GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+3)] == "'")   //右侧的有'
                                        {
                                            str=String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+2)])+String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+3)])
                                            s=s+2
                                        }
                                        else    //右侧为单个字符，判断是不是文法左部
                                        {
                                            str=String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+2)])
                                        }
                                        
                                        if NoSymbol[str] != nil
                                        {
                                            for t in 0..<GramList.count
                                            {
                                                if GramList[t].leftS == str
                                                {
                                                    for tt in GramList[t].firstSet
                                                    {
                                                        if tt != "ε"
                                                        {
                                                            if GramList[i].followSet.indexOf(tt) == nil
                                                            {
                                                                GramList[i].followSet.append(tt)
                                                            }
                                                        }
                                                        else
                                                        {
                                                            hasnil=true
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            if GramList[i].followSet.indexOf(str) == nil
                                            {
                                                GramList[i].followSet.append(str)
                                            }
                                        }
                                    }
                                    else    //右侧没有字母了
                                    {
                                        let follow=GramList[j].followSet
                                        if follow.count>0
                                        {
                                            for k in follow
                                            {
                                                if GramList[i].followSet.indexOf(k) == nil
                                                {
                                                    GramList[i].followSet.append(k)
                                                }
                                            }
                                        }
                                        else    //又要求左边这个的follow...无穷无尽啊！！
                                        {
                                            if GramList[i].leftS != GramList[j].leftS
                                            {
                                                GetFollowSet(&followSet, SearchS: GramList[j].leftS, Shasnil: &hasnil)
                                                for k in followSet
                                                {
                                                    if GramList[j].followSet.indexOf(k) == nil
                                                    {
                                                        GramList[j].followSet.append(k)
                                                    }
                                                    if GramList[i].followSet.indexOf(k) == nil
                                                    {
                                                        GramList[i].followSet.append(k)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        
                    }
                }
            }
        }
        
        
        returnStr+="最终Follow集结果：\n"
        for grammar in GramList
        {
            
            var s:String=""
            s=grammar.leftS+"->"
            s=s+grammar.followSet[0]
            for j in 1..<grammar.followSet.count
            {
                s=s+"|"+grammar.followSet[j]
            }
            returnStr+=s+"\n"
        }
    }
    
    func GetFollowSet(inout SfollowSet:[String],SearchS:String,inout Shasnil:Bool)
    {
        if (SearchS == StartSymbol)     //开始的节点，加入＃
        {
            if (SfollowSet.indexOf("#") == nil)
            {
                SfollowSet.append("#")
            }
        }
        for j in 0..<GramList.count //查找的grammar
        {
            for k in 0..<GramList[j].rightS.count   //查找的grammar的右部
            {
                if SearchS.characters.count==1    //单个字母
                {
                    for pp in 0..<GramList[j].rightS[k].characters.count
                    {
                        var s=pp
                        if (s<GramList[j].rightS[k].characters.count-1 && String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s)]) == SearchS && String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+1)]) != "'") || (s == GramList[j].rightS[k].characters.count-1 && String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s)]) == SearchS) //i左部有相等的右部
                        {
                            var hasnil=true
                            s=s-1
                            while hasnil == true
                            {
                                s=s+1
                                if s<=GramList[j].rightS[k].characters.count-1
                                {
                                    if (GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s)]) == "'"
                                    {
                                        continue
                                    }
                                }
                                hasnil=false
                                var followSet:[String]=[]
                                if s<GramList[j].rightS[k].characters.count-1   //右侧还有字母
                                {
                                    var str=""
                                    if (s<GramList[j].rightS[k].characters.count-2 && GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+2)] == "'")   //右侧的有'
                                    {
                                        str=String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+1)])+String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+2)])
                                        s=s+1
                                        
                                    }
                                    else    //右侧为单个字符，判断是不是文法左部
                                    {
                                        str=String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+1)])
                                    }
                                    if NoSymbol[str] != nil
                                    {
                                        for t in 0..<GramList.count
                                        {
                                            if GramList[t].leftS == str
                                            {
                                                for tt in GramList[t].firstSet
                                                {
                                                    if tt != "ε"
                                                    {
                                                        if (SfollowSet.indexOf(tt) == nil)
                                                        {
                                                            SfollowSet.append(tt)
                                                        }
                                                    }
                                                    else
                                                    {
                                                        hasnil=true
                                                        Shasnil=true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        SfollowSet.append(str)
                                    }
                                }
                                else    //右侧没有字母了
                                {
                                    let follow=GramList[j].followSet
                                    if follow.count>0
                                    {
                                        for k in follow
                                        {
                                            if SfollowSet.indexOf(k) == nil
                                            {
                                                SfollowSet.append(k)
                                            }
                                        }
                                    }
                                    else    //又要求左边这个的follow...无穷无尽啊！！
                                    {
                                        if SearchS != GramList[j].leftS
                                        {
                                            GetFollowSet(&followSet, SearchS: GramList[j].leftS, Shasnil: &hasnil)
                                            for k in followSet
                                            {
                                                if GramList[j].followSet.indexOf(k) == nil
                                                {
                                                    GramList[j].followSet.append(k)
                                                }
                                                if SfollowSet.indexOf(k) == nil
                                                {
                                                    SfollowSet.append(k)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else        //俩字母，带'
                {
                    for pp in 0..<GramList[j].rightS[k].characters.count
                    {
                        var s=pp
                        if (s == GramList[j].rightS[k].characters.count-1)
                            {break}
                        if String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s)])+String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+1)]) == SearchS   //i左部有相等的右部
                        {
                            var hasnil=true
                            s=s-1
                            while hasnil==true
                            {
                                s=s+1
                                if s<=GramList[j].rightS[k].characters.count-1
                                {
                                    if (GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s)]) == "'"
                                    {
                                        continue
                                    }
                                }
                                hasnil=false
                                var followSet:[String]=[]
                                if s<GramList[j].rightS[k].characters.count-2   //右侧还有字母
                                {
                                    var str=""
                                    if (s<GramList[j].rightS[k].characters.count-3 && GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+3)] == "'")   //右侧的有'
                                    {
                                        str=String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+2)])+String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+3)])
                                        s=s+2
                                    }
                                    else    //右侧为单个字符，判断是不是文法左部
                                    {
                                        str=String(GramList[j].rightS[k][GramList[j].rightS[k].startIndex.advancedBy(s+2)])
                                    }
                                    
                                    if NoSymbol[str] != nil
                                    {
                                        for t in 0..<GramList.count
                                        {
                                            if GramList[t].leftS == str
                                            {
                                                for tt in GramList[t].firstSet
                                                {
                                                    if tt != "ε"
                                                    {
                                                        if (SfollowSet.indexOf(tt) == nil)
                                                        {
                                                            SfollowSet.append(tt)
                                                        }
                                                    }
                                                    else
                                                    {
                                                        hasnil=true
                                                        Shasnil=true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else
                                    {
                                        if (SfollowSet.indexOf(str) == nil)
                                        {
                                            SfollowSet.append(str)
                                        }
                                    }
                                }
                                else    //右侧没有字母了
                                {
                                    let follow=GramList[j].followSet
                                    if follow.count>0
                                    {
                                        for k in follow
                                        {
                                            if SfollowSet.indexOf(k) == nil
                                            {
                                                SfollowSet.append(k)
                                            }
                                        }
                                    }
                                    else    //又要求左边这个的follow...无穷无尽啊！！
                                    {
                                        if SearchS != GramList[j].leftS
                                        {
                                            GetFollowSet(&followSet, SearchS: GramList[j].leftS, Shasnil: &hasnil)
                                            for k in followSet
                                            {
                                                if GramList[j].followSet.indexOf(k) == nil
                                                {
                                                    GramList[j].followSet.append(k)
                                                }
                                                if SfollowSet.indexOf(k) == nil
                                                {
                                                    SfollowSet.append(k)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    
                }
            }
        }
    }
    
    
    func CreateTable()
    {
        //求终结符
        for gram in GramList
        {
            for right in gram.rightS
            {
                for i in 0..<right.characters.count
                {
                    if i<right.characters.count-1   //后面还有字符
                    {
                        if right[right.startIndex.advancedBy(i+1)] == "'"   //这和下一个连在一起是类似于S'的东西
                        {
                            continue
                        }
                        let nowchar=String(right[right.startIndex.advancedBy(i)])
                        if (nowchar) != "ε" && nowchar.characters.count>0
                        {
                            if NoSymbol[nowchar] == nil
                            {
                                if (EndSymbol.indexOf(nowchar) == nil)
                                {
                                    EndSymbol.append(nowchar)
                                }
                            }
                        }
                    }
                    else
                    {
                        let nowchar=String(right[right.startIndex.advancedBy(i)])
                        if nowchar != "ε" && nowchar != "'"
                        {
                            if NoSymbol[nowchar] == nil
                            {
                                if (EndSymbol.indexOf(nowchar) == nil)
                                {
                                    EndSymbol.append(nowchar)
                                }
                            }
                        }
                    }
                }
            }
        }
        EndSymbol.append("#")
        returnStr+="非终结符:\n"
        var str=""
        for noend in NoSymbol
        {
            str=str+" "+noend.0
        }
        returnStr+=str+"\n"
        returnStr+="终结符: \n"
        str=""
        for ends in EndSymbol
        {
            str=str+" "+ends
        }
        returnStr+=str+"\n"
        
        //生成表
        for grammar in GramList //对于每个文法G的产生式
        {
            for first in grammar.firstSet
            {
                if first != "ε"     //是空
                {
                    for right in grammar.rightS
                    {
                        if String(right[right.startIndex.advancedBy(0)]) == first
                        {
                            let label=(first,right)
                            if AnalysisTable[grammar.leftS] == nil
                            {
                                AnalysisTable[grammar.leftS]=[]
                            }
                            AnalysisTable[grammar.leftS]!.append(label)
                            break
                        }
                    }
                }
                else        //对于空的处理，follow集
                {
                    for right in grammar.rightS
                    {
                        if String(right[right.startIndex.advancedBy(0)]) == first
                        {
                            var label=(first,right)
                            for follow in grammar.followSet
                            {
                                label=(follow,right)
                                if AnalysisTable[grammar.leftS] == nil
                                {
                                    AnalysisTable[grammar.leftS]=[]
                                }
                                AnalysisTable[grammar.leftS]!.append(label)
                            }
                            break
                        }
                    }
                }
            }
        }
        
        for i in AnalysisTable      //打印乱七八糟的表
        {
            print (i)
        }
        
        
        
        
    }
    
    
    func TestString(s:String) ->Bool
    {
        var stuck:[String]=["#"]
        stuck.append(StartSymbol)
        for char in s.characters
        {
            while NoSymbol[stuck.last!] != nil
            {
                let now=stuck.popLast()!
                let label=AnalysisTable[now]
                if label == nil
                {
                    return false
                }
                for (a,b) in label!
                {
                    if a == String(char)
                    {
                        var str=""
                        for (var ch=b.characters.count-1;ch>=0;ch -= 1)
                        {
                            if b[b.startIndex.advancedBy(ch)] == "'"
                            {
                                ch=ch-1
                                str=String(b[b.startIndex.advancedBy(ch)])+String(b[b.startIndex.advancedBy(ch+1)])
                            }
                            else
                            {
                                str=String(b[b.startIndex.advancedBy(ch)])
                            }
                            stuck.append(str)
                        }
                    }
                }
                
                
            }
            while (stuck.last!) == "ε"
            {
                stuck.popLast()!
            }
            if stuck.popLast()! != String(char)
            {
                return false
            }
        }
        if stuck.count == 1
        {
            return true
        }
        else
        {
            return false
        }
        
    }

}