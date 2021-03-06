defmodule FlipCardCoreTest do
  use ExUnit.Case
  test "flip card by order test" do
    monster = Data.Cards.get(7).become_monster
    monster = monster.presentation :defense_down
    monster = monster.presentation_changed false
    player_battle_info1 = BattlePlayerInfo[player_pid: self,monster_zone: HashDict.new([{2,monster}])]
    battle_data = BattleData[turn_count: 1,operator_id: 6,phase: :mp1,player1_id: 6,player2_id: 8,
    player1_battle_info: player_battle_info1,player2_battle_info: player_battle_info1]

    {result,battle_data} = FlipCardCore.flip_card 6,2,battle_data
    assert result == :ok
    assert battle_data.player1_battle_info.monster_zone[2].presentation == :attack
    assert battle_data.player1_battle_info.monster_zone[2].presentation_changed == true
    receive do
      {:send,message}->
        assert message == <<0, 23, 46, 233, 0, 1, 0, 0, 0, 4, 0, 3, 55, 59, 49, 0, 1, 0, 0, 0, 6, 1, 2>>
    end
  end
end