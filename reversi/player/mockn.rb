module Reversi
  module Player
    # 座標の重み付けを用いた評価
    module PointScore
      def configure
        # 何手先まで読むか
        @max_depth = 1
        init_point_score
      end

      def evaluate(disc, board, base_board, options = {})
        # 空きマスの数(ターン計算に使用)
        space = board.discs.map{|d| d.space?}.count(true)

        valuation  = 0
        # 座標の重み付けを加算
        valuation += point_score(disc)
        stats = board.stats(board.player)
        # 戦略を変える
        case space
        when (0..15)
          # 終盤：確定石よりも量を優先してとる
          valuation += stats[:fixed].size
          valuation += stats[:movable].size * 2
        else
          # 序盤：確定石を優先し、量を少なくとる
          valuation += stats[:fixed].size   * 10
          valuation += stats[:movable].size * -1
        end

        valuation
      end

      def point_score(disc)
        @point_score[disc.x][disc.y]
      end

      # 座標の重み付け
      def init_point_score()
        default_score = -1  # デフォルトの重み
        @point_score = Array.new(@size){|x| Array.new(@size){|y| default_score}}

        [0, @size-1].repeated_permutation(2).each do |x, y|
          # 四隅
          @point_score[x][y] = 30
          # 四隅の隣(斜めはなし)
          @point_score[x][y-1] = -12 if @game.board.get(x, y-1)
          @point_score[x-1][y] = -12 if @game.board.get(x-1, y)
          @point_score[x][y+1] = -12 if @game.board.get(x, y+1)
          @point_score[x+1][y] = -12 if @game.board.get(x+1, y)
        end

        # 星
        [1, @size-2].repeated_permutation(2).each do |x, y|
          @point_score[x][y] = -15
          # 星の斜め
          [1, -1].repeated_permutation(2).each do |i,j|
            next if @point_score[x+i][y+j] != default_score
            @point_score[x+i][y+j] = 0 if @game.board.get(x+i, y+j)
          end
        end

        (0...@size).to_a.repeated_permutation(2).each do |x, y|
          # 辺
          if x == 1 || y == 1 || x == @size-2 || y == @size-2
            next if @point_score[x][y] != default_score
            @point_score[x][y] = -3
          end
        end

        # FIXME:盤面の重み付け
        if false
          @point_score.each do |x|
            x.each do |val|
              printf("[%4d  ]", val)
            end
            print "\n"
          end
          exit 0
        end
      end
    end

    class Mockn < Player::Base
      # どのアルゴリズムを使うか
      include PointScore
    end
  end
end

