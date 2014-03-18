module Reversi
    module Player
        class Kamitsuki < Player::Base
            def configure
                @max_depth = 3
                @space_num
                initialize_point_score
            end

            def select(board, timeout = 5)
                board = board.dup
                kami_bord = Kamitsuki_Board.new;
                kami_bord.discs = board.discs
                kami_bord.player = board.player
                kami_bord.size = board.size
                board.canvas = nil
                ret = [nil, 0] #[disc, evaluation]
                @evaluation = 0
                @space_num = 0
                board.discs.each do |disc|
                    if disc.color == Disc::SPACE
                        @space_num += 1
                    end
                end
                realtime = Benchmark.realtime {
                    thinker = Thread.new do
                        ret = lookup(0, kami_bord)
                        #trace "%d" % [@space_num]
                    end
                    killer = Thread.new(thinker, timeout) do |thinker, timeout|
                        sleep timeout
                        Thread::kill(thinker) if thinker.alive?
                    end
                    thinker.join

                    #選択されなかったとき or Timeout したときは、ランダムで選択
                    if ret[0] == nil
                        trace "%s: Timeouted (%s)" % [Disc.icon(board.player), timeout]
                        ret = [board.movable.sample(1).shift, 0]
                    end
                }
                @@realtime[@mycolor] += realtime
                @@evaluation[@mycolor] += @evaluation
                trace "%s: (%d, %d) %5dpt %2.1fs (%5d, %2.2fms)" % [Disc.icon(board.player), ret[0].x, ret[0].y, ret[1], realtime, @evaluation, (@@realtime[@mycolor]*1000)/@@evaluation[@mycolor]]
                ret[0]
            end

            def undo (board, base, array)
                board.discs[base.x+base.y*board.size].color = Disc::SPACE
                array.each do |val|
                    board.discs[val].reverse!
                end
            end

            def abcut?(player, parent_ab, val)
                if player == @mycolor &&  val > parent_ab
                    return true
                elsif player != @mycolor &&  val < parent_ab
                    return true
                end
                return false
            end

            def lookup(depth, board, options = {})
                # 最後まで読めた場合は(自分のdisc-相手のdisc)を評価値として返す。
                if board.over?
                    return [nil, evaluate_last(board)]
                end
                # discを置ける場所が無い場合は極端な値を返す
                if board.movable.size == 0
                    return [nil, board.player == @mycolor ? 2147483647 : -2147483647]
                end
                # 残りが10手以上残っている場合は@max_depthの深さまでの探索とする
                if depth > @max_depth && @space_num > 10
                    return [nil, evaluate(options[:moved], board, board, options)]
                end

                # 現在のプレイヤーを保存
                temp_player = board.player

                # 現在の選択可能な打ち手について、子ノードの評価値を求める。
                plans = {}
                board.movable.each do |disc|
                    @evaluation += 1

                    # discを置く
                    flip_array = board.move(disc, board.player)

                    # 現在の候補の中で最小値or最大値を求める
                    val = 0
                    if plans.size != 0
                        if temp_player == @mycolor
                            val = plans.max{|a,b| a[1] <=> b[1]}[1]
                        else
                            val = plans.min{|a,b| a[1] <=> b[1]}[1]
                            #trace "min"
                        end
                    end

                    plans[disc] = lookup(depth+1, board, options.merge({:moved => disc, :ab=>val}))[1]

                    # 盤面とplayerを元に戻す
                    undo(board, disc, flip_array)
                    board.player = temp_player

                    # alpha-beta法のための処理
                    if options.key?(:ab)  && abcut?(temp_player, options[:ab], plans[disc])
                        break
                    end
                end

                # 子ノードの評価値のうち、最も有効となる手を選択肢、ノードの評価値として返す。
                if temp_player == @mycolor
                    disc = plans.max{|a,b| a[1] <=> b[1]}[0]
                else
                    disc = plans.min{|a,b| a[1] <=> b[1]}[0]
                end
                return [disc, plans[disc]] #打ち手 と 評価値を返す。
            end

            def evaluate(disc, board, base_board, options = {})
                player = board.player
                stats = [base_board.stats(player), board.stats(player)]
                if @debug
                    #trace("%s: (%d, %d) - score=%d, movable=%d, fixed=%d" % [
                    #Disc.icon(player), disc.x, disc.y,
                    #stats[1][:score] - stats[0][:score],
                    #stats[1][:movable].size,
                    #stats[1][:fixed].size - stats[0][:fixed].size])
                end

                valuation  = 0
                #valuation += (stats[1][:movable].size) * 25
                #valuation += (stats[1][:fixed].size - stats[0][:fixed].size) * 500
                valuation += point_score(board)
                return valuation
            end

            def evaluate_last(board)
                my_count = 0

                board.discs.each{ |disc|
                if(disc.color == @mycolor)
                    my_count += 1
                elsif (disc.color != Disc::SPACE)
                    my_count -= 1
                end
                }
                return my_count
            end

            def point_score(board)
              my_count = 0

              board.discs.each{ |disc|
                if(disc.color == @mycolor)
                  my_count += @point_score[disc.x][disc.y]
                elsif(disc.color != Disc::SPACE)
                  my_count -= @point_score[disc.x][disc.y]
                end
              }
              return my_count

            end

            def initialize_point_score()
                @point_score = Array.new(@size){|x| Array.new(@size){|y| -1}}

                [0, @size-1].repeated_permutation(2).each do |x, y|
                    #四隅 と その周辺
                    @point_score[x][y] = 100
                    base = @game.board.get(x, y)
                    @game.board.directions.each do |ox, oy|
                        if (d = base.offset(ox, oy))
                            @point_score[d.x][d.y] = (ox.abs == oy.abs ? -50 : -30)
                        end
                    end

                    # 四隅の周辺の周囲
                    [0, 2, -2].repeated_permutation(2).each do |ox, oy|
                        next if ox == 0 && oy == 0
                        if (d = base.offset(ox, oy))
                            @point_score[d.x][d.y] = 0
                        end
                    end
                end

                # 辺の内側
                (0..(@size-1)).each do |x|
                    (0..(@size-1)).each do |y|
                        if ((x == 1 || y == 1 || x == (@size - 1) || y == (@size - 1)) && @point_score[x][y] == -1)
                            @point_score[x][y] = -3
                        end
                    end
                end

                # デバッグ
                (0..(@size-1)).each{|x| (0..(@size-1)).each{|y| print "%04s" % [@point_score[x][y]]}; print "\n" }
            end
        end
    end

    class Kamitsuki_Board < Board

        def reverse(base, color)
            ret = [];
            directions.each do |x, y|
                next unless reversible?(base, color, {:x => x, :y => y})
                for i in (1..@size) do
                    d = base.offset(x*i, y*i)
                    # logger.trace("%s: %s (%d,%d)" % [base, d, x*i, y*i])
                    if (d == nil || d.space? || d.color == color)
                        break
                    end
                    d.reverse!
                    ret << d.x+d.y*@size
                    #@canvas.reversed(self) if @canvas
                end
                end
                return ret
            end

            def move(disc, player = @player)
                disc = get(disc.x, disc.y)
                @selected = disc
                disc.color = player
                ret = reverse(disc, player)
                next_player!
                #stats!
                if pass?
                    @logs << Disc.icon(@player) + ": PASS"
                    next_player!
                end
                ret
            end
        end
end