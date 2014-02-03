module Reversi
  module Player
    class Kobayashi < Player::Base
      def configure
        @max_depth = 2
        initialize_point_score
      end

      def evaluate(disc, board, base_board, options = {})
        player = board.player
        stats = [base_board.stats(player), board.stats(player)]
        if @debug
          trace("%s: (%d, %d) - score=%d, movable=%d, fixed=%d" % [
            Disc.icon(player), disc.x, disc.y,
            stats[1][:score] - stats[0][:score],
            stats[1][:movable].size,
            stats[1][:fixed].size - stats[0][:fixed].size])
        end

        valuation  = (stats[1][:score] - stats[0][:score])
        valuation += (stats[1][:movable].size) * 25
        valuation += (stats[1][:fixed].size - stats[0][:fixed].size) * 500
        valuation += point_score(disc)
        valuation
      end

      def point_score(disc)
        @point_score[disc.x][disc.y]
      end

      def initialize_point_score()
        @point_score = Array.new(@size){|x| Array.new(@size){|y| 0}}

        #四隅 と その周辺
        [0, @size-1].repeated_permutation(2).each do |x, y|
          @point_score[x][y] = 250
          base = @game.board.get(x, y)
          @game.board.directions.each do |ox, oy|
            sc = base.offset(ox, oy)
            @point_score[sc.x][sc.y] = -250 if sc
          end
        end
      end
    end
  end
end
