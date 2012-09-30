module BlindAttacker
  def target
    closest(Character)
  end

  def next_move
    return nil unless target
    return nil if distance(target.x, target.y) <= atk_range

    $board.tiles.flatten.
      select{|tile|
        !tile.occupied? &&
        distance(tile.x, tile.y) <= range &&
        target.distance(tile.x, tile.y) >= atk_range
      }.
      sort_by{|tile| target.distance(tile.x, tile.y)}.
      first
  end

  def next_attack
    return nil unless target

    distance(target.x, target.y) <= atk_range && target
  end
end
