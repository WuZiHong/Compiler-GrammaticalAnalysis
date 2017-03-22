//
//  ViewController.swift
//  GrammaticalAnalysisStory
//
//  Created by 吴子鸿 on 16/9/29.
//  Copyright © 2016年 吴子鸿. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate {

    @IBOutlet weak var TableView: NSTableView!
    
    @IBOutlet var ShowText: NSTextView!
    
    @IBOutlet weak var TestText: NSTextField!
    @IBOutlet weak var GramNum: NSTextField!    //产生式个数
    
    @IBOutlet weak var LeftLabel: NSTextField!
    
    @IBOutlet weak var RightLabel: NSTextField!
    var nownum=0
    
    var Num:Int=0
    
    var StartCh:String=""
    
    var GramList:[GrammarStruct]=[]
    
    var grammar:GrammarStruct=GrammarStruct()
    
    var tableviewColumn:[NSTableColumn]=[]
    
    @IBOutlet weak var BeginChar: NSTextField!  //起始字母
    
    @IBOutlet weak var GramLeft: NSTextField!   //产生式左部
    
    @IBOutlet weak var GramRight: NSTextField!  //产生式右部
    
    @IBOutlet weak var SubmitButton: NSButton!
    
    @IBOutlet weak var AddButt: NSButton!
    
    var tableArr:[[String]]=[[]]
    
    var Machine:GrammaticalClass!
    override func viewDidLoad() {
        super.viewDidLoad()
        ShowText.editable=false
        
        for i in TableView.tableColumns
        {
            TableView.removeTableColumn(i)
        }
        tableviewColumn=[]
        // Do any additional setup after loading the view.
    }
    var AnalysisTable:[String:[(String,String)]]=[:]      // [非终结符:(终结符,转移的式子)]
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func SubmitInit(sender: NSButton) {
        Num=GramNum.integerValue
        StartCh=BeginChar.stringValue
        
        nownum=1;
        LeftLabel.stringValue="第\(nownum)个产生式左部"
        RightLabel.stringValue="第\(nownum)个产生式右部"
        
        SubmitButton.enabled=false
        
    }

    
    @IBAction func AddButton(sender: NSButton) {
        if AddButt.title == "计算"
        {
            
            var x:Bool=false
            for i in 0..<GramList.count
            {
                if GramList[i].leftS == GramLeft.stringValue
                {
                    GramList[i].rightS.append(GramRight.stringValue)
                    x=true
                }
            }
            if x == false
            {
                grammar.rightS=[]
                grammar.leftS=GramLeft.stringValue
                grammar.rightS.append(GramRight.stringValue)
                GramList.append(grammar)
            }
            GramLeft.stringValue = ""
            GramRight.stringValue = ""
            
            Machine=GrammaticalClass(gram: GramList,s: "S")
            
            Machine.EliminatingLeftRecursion()        //消除左递归  Bingo  !!!
            
            Machine.CalFirstSet()     //计算first集    right !!!
            
            Machine.CalFollowSet()    //计算follow集   right !!!
            
            Machine.CreateTable();    //构造表   perfect !!!
            
            self.AnalysisTable=Machine.AnalysisTable
            
            ShowText.string=Machine.returnStr
            
            AddButt.enabled=false
            
            tableArr=[]
            //生成二维表
            var head:[String]=[]
            var rowS:[String]=[]
            rowS.append("")
            var newcolumn=NSTableColumn(identifier: String(0))
            newcolumn.width=50
            tableviewColumn.append(newcolumn)
            for i in 1...Machine.EndSymbol.count    //行头
            {
                rowS.append(Machine.EndSymbol[i-1])
                newcolumn=NSTableColumn(identifier: String(i))
                newcolumn.width=50
                tableviewColumn.append(newcolumn)
                
            }
            tableArr.append(rowS)
            head=rowS
            var nowCh:String=""
            var goto:[(String,String)]=[]
            var has:Bool=false
            for row in 0..<Machine.NoSymbol.count
            {
                rowS=[]
                for i in 1...head.count
                {
                    has=false
                    if i==1
                    {
                        nowCh=Machine.NoSymbol[Machine.NoSymbol.startIndex.advancedBy(row)].0
                        rowS.append(nowCh)
                        has=true
                    }
                    else
                    {
                        goto=AnalysisTable[nowCh]!
                        for j in 0..<goto.count
                        {
                            if goto[j].0 == head[i-1]
                            {
                                rowS.append(goto[j].1)
                                has=true
                                break
                            }
                        }
                        
                    }
                    if has == false
                    {
                        rowS.append("nil")
                    }
                }
                tableArr.append(rowS)
            }
            
            for i in 0..<tableArr.count
            {
                var s=""
                for j in 0..<tableArr[i].count
                {
                    s=s+tableArr[i][j]+" "
                }
                print(s)
            }
            
            for column in tableviewColumn
            {
                TableView.addTableColumn(column)
            }
            TableView.reloadData()
            return
        }
        nownum=nownum+1
        if (nownum == Num)
        {
            AddButt.title="计算"
        }

        var x:Bool=false
        for i in 0..<GramList.count
        {
            if GramList[i].leftS == GramLeft.stringValue
            {
                GramList[i].rightS.append(GramRight.stringValue)
                x=true
            }
        }
        if x == false
        {
            grammar.rightS=[]
            grammar.leftS=GramLeft.stringValue
            grammar.rightS.append(GramRight.stringValue)
            GramList.append(grammar)
        }
        GramLeft.stringValue = ""
        GramRight.stringValue = ""
        
        LeftLabel.stringValue="第\(nownum)个产生式左部"
        RightLabel.stringValue="第\(nownum)个产生式右部"
        
    }


    @IBAction func TestButtonClick(sender: NSButton) {
        if (Machine.TestString(TestText.stringValue))
        {
            let myAlert=NSAlert()
            myAlert.messageText="Bingo!"
            myAlert.informativeText="字符串满足文法规则"
            myAlert.alertStyle=NSAlertStyle.InformationalAlertStyle
            myAlert.beginSheetModalForWindow(self.view.window!, completionHandler: { (choice:NSModalResponse) ->
                Void in })
        }
        else
        {
            let myAlert=NSAlert()
            myAlert.messageText="Wrong!"
            myAlert.informativeText="字符串不满足文法规则"
            myAlert.alertStyle=NSAlertStyle.WarningAlertStyle
            myAlert.beginSheetModalForWindow(self.view.window!, completionHandler: { (choice:NSModalResponse) ->
                Void in })
        }
        
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }
        let column=Int(columnIdentifier)
        if column == nil
        {
            return nil
        }
        let cellView = tableView.makeViewWithIdentifier("cell", owner: self) as! NSTableCellView
        print (tableArr[row][column!])
        cellView.textField?.stringValue = tableArr[row][column!]
        
        return cellView
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return tableArr.count
    }

    
}

