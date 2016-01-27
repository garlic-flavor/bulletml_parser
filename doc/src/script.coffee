$ ()->
    ## -------------------------------------------------------------------------
    ##
    ## 定義
    ##
    ## -------------------------------------------------------------------------

    ## 左ペインを保持しておく。
    $lp = $ "#left-pain"
    ## 左ペインの横幅
    maxlp = 0

    ## エレメントが見えているかどうか。
    isVisible = (e)->
        $e = $ e
        (0 < $e.prop "offsetWidth") || (0 < $e.prop "offsetHeight")

    ## 左ペインにモジュール名を登録する。
    ## 引数 e は <dt id="the.name.of.the.module">
    appendToModulesList = (e, title)->
        $e = $ e

        ## 外側 
        $div = $ "<div>"
        $div.attr "name", $e.attr "id"

        ## メンバ展開ボタン
        if not title?
            $expand = $ "<div>"
            $expand.text "+"
            $expand.addClass "expand-button"
            $expand.click (e)->
                $t = $ e.target
                if "+" == $t.text()
                    $ul = $div.children "ul"
                    if 0 == $ul.length
                        $div.append getModuleMembers $e
                    else
                        $ul.show()
                    $t.text "-"
                else
                    $div.children("ul").hide()
                    $t.text "+"
            $div.append $expand

        ## リンク
        title ?= $e.attr "id"
        $a = $ "<a>"
        $a.attr "href", ("#" + $e.attr "id")
        $a.text title
        $div.append $a

        $lp.append $div

    ## 位置合わせ
    setPosition = ()->
        if isVisible $lp
            $lp.innerWidth maxlp + $lp.outerWidth() - $lp.prop "clientWidth"
            left = $lp.offset().left + $lp.outerWidth()
            ($ "#main-pain").css "left",  left
            ($ "#main-title").css "margin-left", left
        else
            ($ "#main-pain").css "left", 0
            ($ "#main-title").css "margin-left", 0


    ## 現在見えているモジュールをハイライト
    setActiveModule = ()->
        ## 直前のやつをクリア
        $lp.children().removeClass "active"
        found = false

        ## 巡回して探す
        wh = ($ window).innerHeight()
        ($ "#modules").children("dt").each (i, e)->
            rc = ($ e).next()[0]?.getBoundingClientRect()
            if not found and rc.top < wh and 0 <= rc.bottom
                found = true
                $lp.children("[name='" + e.id + "']").addClass "active"


    ## モジュール内のメンバを列挙し、<ul>を返す
    ## 引数としては、<dt id="the.name.of.the.module"> を渡す。
    getModuleMembers = (e)->
        $e = ($ e).next("dd")
        $ul = $ "<ul>"
        appendMembersMembers $ul, $e.children "dl.module-members-sec"

    ## メンバと、さらにそのメンバを再帰的に列挙する。
    ## getModuleMembers から呼ばれる。
    appendMembersMembers = ($ul, $elems)->
        $elems.each (_, e)->
            ($ e).children("dt").each (_, e2)->
                $e2 = $ e2
                $decl = $e2.find "a.anchor:first"
                $li = $ "<li>"
                $a = $ "<a>"
                name = $decl.attr "name"
                l = name.indexOf(".")
                ## オーバーロードがある場合、名称の後に .2 .3 とかつく為
                if 0 < l
                    nname = name.substring l+1
                    if isNaN parseInt nname
                        name = nname
                    else
                        name = name.substring 0, l
                $a.text name
                $a.attr "href", "#" + $decl.attr "id"
                $li.append($a)
                $ul.append($li)

                $ul2 = $ "<ul>"
                appendMembersMembers $ul2
                    , $e2.next("dd").children "dl.members-sec"

                $ul.append $ul2
        $ul


    ## -------------------------------------------------------------------------
    ##
    ## 実行
    ##
    ## -------------------------------------------------------------------------

    ## イベントハンドラの登録
    ($ window).resize ()->setPosition()
    ($ window).scroll ()->setActiveModule()

    ## 左ペインを隠す/出すボタン
    (()->
        $btn = $ "<button>"
        $btn.text "-"
        $btn.css position: "fixed", left: "0", top: "0"
        $btn.click ()->
            if $btn.text() is "-"
                $lp.hide()
                $btn.text "+"
            else
                $lp.show()
                $btn.text "-"
            setPosition()
        $btn.appendTo document.body
        $lp.css "top", $btn.outerHeight()
    )()

    ## メインのヘッダだけ表示する。
    $("#modules > dd:first .summary-header-sec").show()

    ## 左ペインにモジュールを追加
    ($ "#modules").children("dt").each (_, e)-> appendToModulesList e
    maxlp = $lp.outerWidth()


    ## 位置合わせ
    setPosition()
    setActiveModule()
