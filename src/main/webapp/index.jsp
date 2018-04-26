<html>      
    <head>      
        <title>R</title>      
        <style>      
            #board tr td{      
                width: 20px;      
                height: 20px;      
            }    
            #main{    
                float: left;    
            }    
            #preBoard tr td{    
                width: 20px;     
                height: 20px;    
            }    
        </style>      
    </head>      
    <script>  
    /************************************************************  
    * JS俄罗斯方块完美注释版 v 1.01  
    * 作者: sunxing007  
    * 转载请说明来自: http://blog.csdn.net/sunxing007  
    *************************************************************/   
      
    /************************************************************      
    * JS俄罗斯方块完美注释版 v 1.01     
    * 从学c语言那一会儿都想写一个俄罗斯方块,可是每次动起手总觉得难度太大.     
    * 今天终于用了大约4个小时写出来了. 其中在涉及到方块变型的时候还咨询了     
     * 同学来帮忙;     
    *     
    * 个人觉得难点有这么几个:     
    * 1: 边界检查, 不多说, 想通了就行     
     * 2: 旋转, 还是数学上的方法, 一个点相对另外一个点旋转90度的问题.      
    * 4: 让整个程序在点开始之后, 怎么让它一直自动的运行下去. 我以前一直没有做完,     
    *    主要是因为没有想清楚到底要用一个什么机制让游戏自动运行下去,      
    *    这个过程可以这么理解:     
    *    用户点开始->构造一个活动图形, 设置定时器,      
    *    每次向下移动后, 都检查是否触底, 如果触底了, 则尝试消行,     
    *    完了之后再构造一个活动图形, 再设置定时器.     
    */      
        //表示页面中的table, 这个table就是将要显示游戏的主面板     
        var tbl;     
        //预览窗口    
        var preTbl;     
        //游戏状态 0: 未开始;1 运行; 2 中止;     
        var status = 0;      
        //定时器, 定时器内将做moveDown操作     
        var timer;     
        //分数     
        var score = 0;     
        //board是一个18*10的数组,也和页面的table对应.     
        //用来标注那些方格已经被占据. 初始时都为0, 如果被占据则为1     
        var board = new Array(18);     
        for(var i=0;i<18;i++){     
            board[i] = new Array(10);      
        }     
        for(var i=0;i<18;i++){      
            for(var j=0; j<10; j++){      
                board[i][j] = 0;      
            }      
        }      
              
        //当前活动的方块, 它可以左右下移动, 变型.当它触底后, 将会更新board;     
        var activeBlock;    
        //下一个图形    
        var nextBlock;    
        //下一个图形预览    
        var previewBlock;    
       //生产方块形状, 有7种基本形状.     
        function generateBlock(){      
            var block = new Array(4);      
            //generate a random int number between 0-6;      
            var t = (Math.floor(Math.random()*20)+1)%7;      
            switch(t){    
                case 0:{      
                    block[0] = {x:0, y:4};      
                    block[1] = {x:1, y:4};      
                    block[2] = {x:0, y:5};      
                    block[3] = {x:1, y:5};      
                    break;      
                }      
                case 1:{      
                    block[0] = {x:0, y:3};      
                    block[1] = {x:0, y:4};      
                    block[2] = {x:0, y:5};      
                    block[3] = {x:0, y:6};      
                    break;      
                }      
                case 2:{      
                    block[0] = {x:0, y:5};      
                    block[1] = {x:1, y:4};      
                    block[2] = {x:1, y:5};      
                    block[3] = {x:2, y:4};      
                    break;      
                }      
                case 3:{      
                    block[0] = {x:0, y:4};      
                    block[1] = {x:1, y:4};      
                    block[2] = {x:1, y:5};      
                    block[3] = {x:2, y:5};      
                    break;      
                }      
                case 4:{      
                    block[0] = {x:0, y:4};      
                    block[1] = {x:1, y:4};      
                    block[2] = {x:1, y:5};      
                    block[3] = {x:1, y:6};      
                    break;      
                }      
                case 5:{      
                    block[0] = {x:0, y:4};      
                    block[1] = {x:1, y:4};      
                    block[2] = {x:2, y:4};      
                    block[3] = {x:2, y:5};      
                    break;      
                }      
                case 6:{      
                    block[0] = {x:0, y:5};      
                    block[1] = {x:1, y:4};      
                    block[2] = {x:1, y:5};      
                    block[3] = {x:1, y:6};      
                    break;      
                }     
            }    
            return block;     
        }     
        //向下移动     
        function moveDown(){     
            //检查底边界.     
          if(checkBottomBorder()){      
            //没有触底, 则擦除当前图形,      
              erase();      
              //更新当前图形坐标     
              for(var i=0; i<4; i++){     
                  activeBlock[i].x = activeBlock[i].x + 1;      
              }     
              //重画当前图形     
              paint();      
          }     
          //触底,      
          else{     
            //停止当前的定时器, 也就是停止自动向下移动.     
            clearInterval(timer);     
            //更新board数组.     
            updateBoard();     
            //消行     
            var lines = deleteLine();     
            //如果有消行, 则     
            if(lines!=0){     
                //更新分数     
                //一次消多行则分数加倍    
                if(lines==2){    
                    lines=3;    
                }    
                else if(lines==3){    
                    lines=6;    
                }    
                else if(lines==4){    
                    lines=10;    
                }    
                score = score + lines;     
                updateScore();    
                //擦除整个面板     
                eraseBoard();     
                //重绘面板     
                paintBoard();     
            }    
            erasePreview();    
            //产生一个新图形并判断是否可以放在最初的位置.     
            if(!validateBlock(nextBlock)){    
                alert("Game over1111!");     
                status = 2;    
                return;     
            };    
            activeBlock = nextBlock;    
            nextBlock = generateBlock();    
            previewBlock = copyBlock(nextBlock);    
            paint();    
            //定时器, 每隔一秒执行一次moveDown    
            applyPreview();    
            paintPreview();    
            timer = setInterval(moveDown,1000)     
          }      
        }    
        function validateBlock(block){    
            if(!block){    
                //alert("next block is null.");    
                return false;    
            }    
          for(var i=0; i<4; i++){     
              if(!isCellValid(block[i].x, block[i].y)){    
                    //alert("a cell is invalid.");    
                  return false;     
              }     
          }    
          return true;    
        }    
            
        //左移动     
        function moveLeft(){     
            if(checkLeftBorder()){      
                erase();      
                for(var i=0; i<4; i++){      
                    activeBlock[i].y = activeBlock[i].y - 1;      
                }      
                paint();      
            }      
        }      
        //右移动     
        function moveRight(){      
            if(checkRightBorder()){      
                erase();      
                for(var i=0; i<4; i++){      
                    activeBlock[i].y = activeBlock[i].y + 1;      
                }      
                paint();      
            }      
        }      
        //旋转, 因为旋转之后可能会有方格覆盖已有的方格.     
        //先用一个tmpBlock,把activeBlock的内容都拷贝到tmpBlock,     
        //对tmpBlock尝试旋转, 如果旋转后检测发现没有方格产生冲突,则     
        //把旋转后的tmpBlock的值给activeBlock.     
        function rotate(){      
            var tmpBlock = copyBlock(activeBlock);     
            //先算四个点的中心点，则这四个点围绕中心旋转90度。    
            var cx = Math.round((tmpBlock[0].x + tmpBlock[1].x + tmpBlock[2].x + tmpBlock[3].x)/4);      
            var cy = Math.round((tmpBlock[0].y + tmpBlock[1].y + tmpBlock[2].y + tmpBlock[3].y)/4);      
            //旋转的主要算法. 可以这样分解来理解。    
            //先假设围绕源点旋转。然后再加上中心点的坐标。    
  
            for(var i=0; i<4; i++){      
                tmpBlock[i].x = cx+cy-activeBlock[i].y;     
                tmpBlock[i].y = cy-cx+activeBlock[i].x;     
            }      
            //检查旋转后方格是否合法.     
            for(var i=0; i<4; i++){      
                if(!isCellValid(tmpBlock[i].x,tmpBlock[i].y)){     
                    return;     
                }     
            }     
            //如果合法, 擦除     
            erase();      
            //对activeBlock重新赋值.     
            for(var i=0; i<4; i++){      
                activeBlock[i].x = tmpBlock[i].x;      
                activeBlock[i].y = tmpBlock[i].y;      
            }     
            //重画.     
            paint();      
        }      
        //检查左边界,尝试着朝左边移动一个,看是否合法.     
        function checkLeftBorder(){      
            for(var i=0; i<activeBlock.length; i++){      
                if(activeBlock[i].y==0){      
                    return false;      
                }      
                if(!isCellValid(activeBlock[i].x, activeBlock[i].y-1)){      
                    return false;      
                }      
            }      
            return true;      
        }      
        //检查右边界,尝试着朝右边移动一个,看是否合法.     
        function checkRightBorder(){      
            for(var i=0; i<activeBlock.length; i++){      
                if(activeBlock[i].y==9){      
                    return false;      
                }      
                if(!isCellValid(activeBlock[i].x, activeBlock[i].y+1)){      
                    return false;      
                }      
            }      
            return true;      
        }      
        //检查底边界,尝试着朝下边移动一个,看是否合法.     
        function checkBottomBorder(){      
            for(var i=0; i<activeBlock.length; i++){      
                if(activeBlock[i].x==17){      
                    return false;      
                }      
                if(!isCellValid(activeBlock[i].x+1, activeBlock[i].y)){      
                    return false;      
                }      
            }      
            return true;      
        }      
        //检查坐标为(x,y)的是否在board种已经存在, 存在说明这个方格不合法.     
        function isCellValid(x, y){      
            if(x>17||x<0||y>9||y<0){      
                return false;      
            }      
            if(board[x][y]==1){      
                return false;      
            }      
            return true;      
        }      
                //擦除     
        function erase(){      
            for(var i=0; i<4; i++){      
                tbl.rows[activeBlock[i].x].cells[activeBlock[i].y].style.backgroundColor="white";      
            }      
        }      
        //绘活动图形     
        function paint(){      
            for(var i=0; i<4; i++){      
                tbl.rows[activeBlock[i].x].cells[activeBlock[i].y].style.backgroundColor="red";      
            }      
        }    
        //绘预览图形    
        function paintPreview(){    
            for(var i=0; i<4; i++){    
                preTbl.rows[previewBlock[i].x].cells[previewBlock[i].y].style.backgroundColor="red";    
            }    
        }    
        //擦除预览图形    
        function erasePreview(){    
            for(var i=0; i<4; i++){    
                preTbl.rows[previewBlock[i].x].cells[previewBlock[i].y].style.backgroundColor="white";    
            }    
        }    
            
        //更新board数组     
        function updateBoard(){      
            for(var i=0; i<4; i++){      
                board[activeBlock[i].x][activeBlock[i].y]=1;      
            }      
        }     
        //消行     
        function deleteLine(){     
            var lines = 0;     
            for(var i=0; i<18; i++){     
                var j=0;     
                for(; j<10; j++){     
                    if(board[i][j]==0){     
                        break;     
                    }     
                }     
                if(j==10){     
                    lines++;     
                    if(i!=0){     
                        for(var k=i-1; k>=0; k--){     
                            board[k+1] = board[k];     
                        }     
                    }     
                    board[0] = generateBlankLine();     
                }     
            }     
            return lines;     
        }     
        //擦除整个面板     
        function eraseBoard(){     
            for(var i=0; i<18; i++){     
                for(var j=0; j<10; j++){     
                    tbl.rows[i].cells[j].style.backgroundColor = "white";     
                }     
            }     
        }     
        //重绘整个面板     
        function paintBoard(){     
            for(var i=0;i<18;i++){     
                for(var j=0; j<10; j++){      
                  if(board[i][j]==1){     
                    tbl.rows[i].cells[j].style.backgroundColor = "red";     
                  }     
                }      
            }      
        }     
        //产生一个空白行.     
        function generateBlankLine(){     
            var line = new Array(10);     
            for(var i=0; i<10; i++){     
                line[i] = 0;     
            }     
            return line;     
        }     
        //更新分数    
        function updateScore(){    
            document.getElementById("score").innerText=" " + score;    
        }    
        //键盘控制     
        function keyControl(){      
            if(status!=1){     
                return;     
            }      
            var code = event.keyCode;      
            switch(code){      
                case 37:{     
                    moveLeft();     
                    break;      
                }      
                case 38:{     
                    rotate();      
                    break;      
                }      
                case 39:{      
                    moveRight();      
                    break;     
                }      
                case 40:{      
                    moveDown();      
                    break;      
                }      
            }      
        }    
        //辅助函数，拷贝一个图形。    
        function copyBlock(old){    
            var o = new Array(4);    
                    for(var i=0; i<4; i++){      
                o[i] = {x:0, y:0};      
          }    
          for(var i=0; i<4; i++){      
                      o[i].x = old[i].x;      
                      o[i].y = old[i].y;      
                    }    
                    return o;    
        }    
        //调整previewBlock的坐标以适应预览窗口    
        function applyPreview(){    
                var t = 100;    
                for(var i=0; i<4; i++){    
                    if(previewBlock[i].y<t){    
                        t = previewBlock[i].y;    
                    }    
                }    
                for(var i=0; i<4; i++){    
                    previewBlock[i].y-=t;    
                }    
                    
        }    
            
        //开始    
        function begin(e){     
                e.disabled = true;     
            status = 1;      
            tbl = document.getElementById("board");    
            preTbl = document.getElementById("preBoard");    
            activeBlock = generateBlock();    
            nextBlock = generateBlock();    
            previewBlock = copyBlock(nextBlock);    
            applyPreview();    
            paint();    
            paintPreview();    
            timer = setInterval(moveDown,1000);     
        }    
        document.onkeydown=keyControl;  
    </script>      
    <body>    
        <Input type="button" value="begin" onclick="begin(this);"/>     Score: <span id="score">  0</span><br><br>    
        <div id="main">    
        <table id="board" cellspacing=0 cellpadding=0 border=1 style="border-collapse:collapse;">      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
            <tr>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
                <td></td>      
            </tr>      
        </table>      
      </div>    
      <div style="float: left; width: 5px;">    
        </div>    
        <div id="pre">    
            <table id="preBoard" cellspacing=0 cellpadding=0 border=1 style="border-collapse:collapse;">    
                <tr>    
                    <td></td>    
                    <td></td>    
                    <td></td>    
                    <td></td>    
                </tr>    
                <tr>    
                    <td></td>    
                    <td></td>    
                    <td></td>    
                    <td></td>    
                </tr>    
                <tr>    
                    <td></td>    
                    <td></td>    
                    <td></td>    
                    <td></td>    
                </tr>    
                <tr>    
                    <td></td>    
                    <td></td>    
                    <td></td>    
                    <td></td>    
                </tr>    
            </table>    
        </div>    
    </body>      
</html>   