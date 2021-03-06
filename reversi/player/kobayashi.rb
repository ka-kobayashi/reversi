# -*- coding: utf-8 -*-
module Reversi
  module Player

    class Node
      attr_accessor :disc, :score
      def initialize(disc, score)
        self.disc = disc
        self.score = score
      end

      def to_a
        [@disc, @score]
      end
    end


    class Kobayashi < Player::Base
      MAX_SCORE =  2147483647
      MIN_SCORE = -2147483647

      def configure
        @max_depth = 3
        initialize_point_score
        @debug = true
      end


      #                       Ｒ                         先手の局面(0)
      #                     ／  ＼
      #                   ／      ＼
      #                 ／          ＼
      #               ／              ＼
      #             ／                  ＼
      #           Ａ(3)                   Ｂ(2)          後手の局面(1)
      #         ／  ＼                  ／  ×
      #       ／      ＼              ／      ×
      #     Ｃ(3)       Ｄ(4)       Ｅ(2)       Ｆ(5)     先手の局面(2)
      #   ／  ＼      ／  ×       ／  ＼      ／  ＼
      # Ｇ      Ｈ  Ｉ      Ｊ   Ｋ     Ｌ  Ｍ      Ｎ     後手の局面(3)
      # １      ３  ４      ２   ２     １  ３      ５     評価値
      #                    ×               ×      ×

      def lookup(depth, board, options = {})
        logger.debug("---------------------------") if @debug
        alphabeta(depth, nil, board, nil, Node.new(nil, MIN_SCORE), Node.new(nil, MAX_SCORE), options).to_a
      end

      def alphabeta(depth, moved_disc, board, base_board, alpha, beta, options = {})
        if depth == @max_depth || board.over?
          return Node.new(moved_disc, evaluate(moved_disc, board, base_board, {:depth => depth}))
        end

        board.movable.each do |disc|
          @evaluation += 1
          new_board = board.dup
          new_board.move(disc, board.player)
          node = Node.new(disc, alphabeta(depth + 1, disc, new_board, board, alpha, beta, options).score)

          if board.player == @mycolor
            if node.score > alpha.score
              alpha = node
            end
            if alpha.score >= beta.score
              return beta
            end
          else
            if node.score < beta.score
              beta = node
            end
            if alpha.score >= beta.score
              return alpha
            end
          end
        end
        return board.player == @mycolor ? alpha : beta
      end


      def evaluate(disc, board, base_board, options = {})
        # 終局した場合、勝敗でスコアを返す。
        if board.over?
          return (board.winner?(@mycolor) ? MAX_SCORE : MIN_SCORE)
        end

        #初期化
        valuation = score = movable = fixed = point = 0

        # 盤面の状況
        stats = {Disc::WHITE => board.stats(Disc::WHITE), Disc::BLACK => board.stats(Disc::BLACK)}

        # 自分の確定石が過半数であったら勝利確定
        if stats[@mycolor][:fixed].size >= board.size*board.size
          valuation += 10000
        elsif stats[enemy][:fixed].size >= board.size*board.size
          valuation -= 10000
        end

        [Disc::WHITE, Disc::BLACK].each do |c|
          score   += (c == @mycolor ? 1 : -1) * stats[c][:score]
          movable += (c == @mycolor ? 1 : -1) * stats[c][:movable].size * 50
          fixed   += (c == @mycolor ? 1 : -1) * stats[c][:fixed].size   * 500
        end
        point = point_score(disc) * (opening?(board) ? 50 : 25)

        #パスさせられるなら高得点
        if stats[enemy][:movable].size == 0
          movable += 5000
        end

        valuation = score + movable + fixed + point + Random.new(Time.now.to_i).rand(100)

        if @debug
          logger.trace('%s: (%d, %d) [%d] total=%d, score=%d, movable=%d, fixed=%d, point=%d, WHITE=%s, BLACK=%s' % [
              Disc.icon(@mycolor), disc.x, disc.y, options[:depth], valuation,
              score, movable, fixed, point,
              inspect_socre(stats[Disc::WHITE]), inspect_socre(stats[Disc::BLACK])
          ])
        end

        return valuation
      end

      def inspect_socre(stats)
        '[s:%d, m:%d, f:%d]' % [stats[:score], stats[:movable].size, stats[:fixed].size]
      end

      def progress(board)
        (board.stats(Disc::WHITE)[:score] + board.stats(Disc::BLACK)[:score]) / (board.size * board.size)
      end

      def opening?(board)
        progress(board) < 0.3
      end

      def closing?(board)
        progress(board) > 0.8
      end


      def point_score(disc)
        disc ? @point_score[disc.x][disc.y] : 0
      end

      def initialize_point_score()
        @point_score = Array.new(@size){|x| Array.new(@size){|y| -1}}

        [0, @size-1].repeated_permutation(2).each do |x, y|
          #四隅 と その周辺
          @point_score[x][y] = 30
          base = @game.board.get(x, y)
          @game.board.directions.each do |ox, oy|
            if (d = base.offset(ox, oy))
              @point_score[d.x][d.y] = (ox.abs == oy.abs ? -15 : -12) 
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
            if (x == 1 || y == 1 || x == (@size - 1) || y == (@size - 1)) && @point_score[x][y] == -1
              @point_score[x][y] = -3
            end
          end
        end

        # デバッグ
        #(0..(@size-1)).each{|x| (0..(@size-1)).each{|y| print "%04s" % [@point_score[x][y]]}; print "\n" }
      end
    end
  end
end
