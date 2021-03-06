defrecord Card,id: 0,card_type: :none,attribute: :none,race: :none,monster_mode: :none,category: :none,group: :none,attack: 0,defense: 0,level: 0,skills: [] do
  @doc """
  become monster card
  """
  def become_monster card_data do
    Monster[id: card_data.id,attack: card_data.attack,race: card_data.race,monster_mode: card_data.monster_mode,group: card_data.group,
    category: card_data.category,attribute: card_data.attribute,defense: card_data.defense,level: card_data.level,skills: card_data.skills]
  end

  @doc """
  become spell trap card
  """
  def become_spell_trap card_data do
    SpellTrap[id: card_data.id,card_type: card_data.card_type,category: card_data.category,skills: card_data.skills]
  end

  @doc """
  get special summon skill
  """
  def get_special_summon_skill card_data do
    case Enum.filter(card_data.skills,&(&1.type == :special_summon_skill)) do
      [skill]->
        skill
      []->
        nil
    end
  end

  @doc """
  get normal skills
  """
  def get_normal_skills card_data do
    Enum.filter card_data.skills,&(&1.type == :normal_skill)
  end

  @doc """
  can be special summoned?
  """
  def can_be_special_summoned? player_id,index,battle_data,card_data do
    case card_data.get_special_summon_skill do
      nil->
        false
      skill->
        skill.is_conditions_satisfied? player_id,:handcard_zone,index,battle_data
    end
  end

  @doc """
  can fire effect
  """
  def can_fire_effect? player_id,index,battle_data,card_data = Card[card_type: :spell_card] do
    case card_data.get_normal_skills do
      []->
        false
      skills->
        Enum.any?(skills,&(&1.is_conditions_satisfied?(player_id,:handcard_zone,index,battle_data)))
    end
  end

  def can_fire_effect? _,_,_,_ do
    false
  end

  @doc """
  get normal summon tribute amount
  """
  def get_normal_summon_tribute_amount(Card[level: level])
  when level<5 do
    0
  end

  def get_normal_summon_tribute_amount(Card[level: level])
  when level in [5,6] do
    1
  end

  def get_normal_summon_tribute_amount(Card[level: level])
  when level in [7,8] do
    2
  end

  def get_normal_summon_tribute_amount(Card[level: level])
  when level in [9,10] do
    3
  end

  @doc """
  can be normal summoned?
  """
  def can_be_tribute_normal_summoned? summoned_count,card_data do
    card_data.get_normal_summon_tribute_amount<=summoned_count
  end

  @doc """
  get normal summon operations
  """
  def get_normal_summon_operations(_player_id,BattleData[normal_summoned: true],_) do
    []
  end

  def get_normal_summon_operations(player_id,battle_data,Card[level: level])
  when level < 5 do
    player_battle_info = battle_data.get_player_battle_info player_id
    if player_battle_info.is_monster_zone_full? do
      []
    else
      [:summon_operation,:place_operation]
    end
  end

  def get_normal_summon_operations(player_id,battle_data,card_data = Card[level: level])
  when level > 4 do
    player_battle_info = battle_data.get_player_battle_info player_id
    summoned_count = player_battle_info.monster_zone_size
    case card_data.can_be_tribute_normal_summoned? summoned_count do
      true->
        [:summon_operation,:place_operation]
      false->
        []
    end
  end

  @doc """
  get special summon operations
  """
  def get_special_summon_operations player_id,index,battle_data,card_data do
    if card_data.can_be_special_summoned?(player_id,index,battle_data) do
      [:special_summon_operation]
    else
      []
    end
  end

  @doc """
  get fire effect operations
  """
  def get_fire_effect_operations player_id,index,battle_data,card_data do
    player_battle_info = battle_data.get_player_battle_info player_id
    if player_battle_info.is_spell_trap_zone_full? do
      []
    else
      if card_data.can_fire_effect?(player_id,index,battle_data) do
        [:fire_effect_operation]
      else
        []
      end
    end
  end
end