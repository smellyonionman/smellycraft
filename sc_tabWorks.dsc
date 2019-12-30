###########################################
# Made by Smellyonionman for Smellycraft. #
#          onion@smellycraft.com          #
#    Tested on Denizen-1.1.2-b4492-DEV    #
#               Version 1.2               #
#-----------------------------------------#
#     Updates and notes are found at:     #
#   https://smellycraft.com/d/tabWorks    #
#-----------------------------------------#
#    You may use, modify or share this    #
#    script, provided you don't remove    #
#    or alter lines 1-13 of this file.    #
###########################################
sc_tw_init:
    type: task
    debug: false
    script:
    - define namespace:sc_tw
    - define admin:<yaml[sc_tw].read[permissions.admin]||<script[sc_tw_defaults].yaml_key[permissions.admin]||tabworks.admin>>
    - define targets:<server.list_online_players.filter[has_permission[<[admin]>]].include[<server.list_online_ops>].deduplicate||<player>>
    - define filename:<script[sc_tw_data].yaml_key[filename]>
    - if <server.has_file[../Smellycraft/<[filename]>]||null>:
      - if <yaml.list.contains[sc_tw]||null>:
        - ~yaml unload id:sc_tw
      - ~yaml load:../Smellycraft/<[filename]> id:sc_tw
    - else:
      - ~yaml create id:sc_tw
      - define payload:<script[sc_tw_defaults].to_json||null>
      - if <[payload].matches[null]>:
        - ~webget https://raw.githubusercontent.com/smellyonionman/smellycraft/master/configs/TabWorks.yml save:sc_raw headers:host/smellycraft.com:443|user-agent/smellycraft
        - define payload:<entry[sc_raw].result>
      - ~yaml loadtext:<[payload]> id:sc_tw
      - yaml set type:! id:sc_tw
    - if <server.object_is_valid[<script[sc_common_init]>].not>:
        - define msg:'<yaml[sc_tw].read[messages.missing_common]||<script[sc_tw_defaults].yaml_key[messages.missing_common]||&cError>>'
        - narrate <[msg].unescaped.parse_color> targets:<[targets]>
        - stop
    - foreach <yaml[sc_tw].list_keys[scripts]||<script[sc_tw_defaults].list_keys[scripts]||<list[narrate|GUI|update]>>> as:task:
      - if <server.object_is_valid[<script[<yaml[sc_tw].read[scripts.<[task]>]||<script[sc_tw_defaults].yaml_key[scripts.<[task]>]>>]>].not>:
        - define placeholder:<yaml[sc_tw].read[messages.missing_script]||<script[sc_tw_defaults].yaml_key[messages.missing_script]||&cError>>
        - narrate '<[placeholder].replace[[script]].with[<[task]>].separated_by[&sp].unescaped.parse_color>' targets:<[targets]>
        - stop
    - ~yaml savefile:../Smellycraft/<[filename]> id:sc_tw
    - yaml set commands.open:! id:sc_tw
    - foreach <server.list_scripts.filter[relative_filename.matches[^scripts/tabs/.*$]]||<list[]>> as:yaml:
      - if <[yaml].list_keys[tabs].size.is[==].to[0]||false>:
        - foreach next
      - ~yaml create id:sc_tw_tabtemp
      - ~yaml loadtext:<[yaml].to_json> id:sc_tw_tabtemp
      - foreach <yaml[sc_tw_tabtemp].list_keys[tabs]>:
        - ~yaml id:sc_tw_tabtemp copykey:tabs.<[value]> tabs.<[value]> to_id:sc_tw
        - ~yaml set tabs.<[value]>.scriptname:<[yaml]> id:sc_tw
        - ~yaml set commands.open.<[value]>:use id:sc_tw
      - ~yaml unload id:sc_tw_tabtemp
    - define feedback:<yaml[sc_tw].read[messages.reload]||<script[sc_tw_defaults].yaml_key[messages.reload]||&cError>>
    - if <[feedback].exists>:
      - inject <script[<yaml[sc_tw].read[scripts.narrator]||<script[sc_tw_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
sc_tw_cmd:
    type: command
    debug: false
    name: tabworks
    description: <yaml[sc_tw].read[messages.description]||Multidimensional GUI fit for almost any purpose.>
    usage: /tabworks
    script:
    - define namespace:sc_tw
    - define use:<yaml[sc_tw].read[permissions.use]||<script[sc_tw_defaults].yaml_key[permissions.use]||tabworks.use>>
    - define admin:<yaml[sc_tw].read[permissions.admin]||<script[sc_tw_defaults].yaml_key[permissions.admin]||tabworks.admin>>
    - if <player.has_permission[<[use]>]||false> || <player.is_op||false> || <context.server>:
      - define selector:<context.args.get[2]||<yaml[sc_tw].read[settings.default]||<script[sc_tw_defaults].yaml_key[settings.default]||options>>>
      - if <context.server.not>:
        - yaml set <player.uuid>.sc_tw.selector:<[selector]> id:sc_pcache
        - yaml set <player.uuid>.sc_tw.index:1 id:sc_pcache
      - if <context.args.size.is[==].to[0]||true>:
        - inventory open d:<inventory[sc_tw_menu]>
      - else:
        - define tabs:!|:<yaml[sc_tw].list_keys[tabs]||<list[]>>
        - if <context.args.size.is[==].to[1]||false>:
          - if <context.args.get[1].to_lowercase.matches[(save|update|reload)]||false>:
            - if <player.has_permission[<[admin]>]||false> || <player.is_op||false> || <context.server>:
              - define arg:<context.args.get[1]>
              - inject <script[sc_common_datacmd]>
          - else if <context.args.get[1].to_lowercase.matches[open]>:
            - define feedback:<yaml[sc_tw].read[messages.badmenu]||<script[sc_tw_defaults].yaml_key[messages.badmenu]||&cError>>
          - else if <context.args.get[1].to_lowercase.matches[credits]>:
            - define feedback:<element[&aTab&2Works&sp&9made&spby&spyour&spfriend&sp&6smellyonionman&nl&9Go&spto&sp&ahttps://smellycraft.com/tabworks&sp&9for&spinfo].>
          - else:
            - define placeholder:<yaml[sc_common].read[messages.admin.args_i]||<script[sc_common_defaults].yaml_key[messages.admin.args_i]||&cError>>
            - define feedback:<[placeholder].replace[[args]].with[<context.args.get[1]>]>
        - else if <context.args.size.is[==].to[2]>:
          - if <context.args.get[1].to_lowercase.matches[open]>:
            - if <[tabs].contains[<[selector]>]||false>:
              - inventory open d:<inventory[sc_tw_menu]>
            - else:
              - define feedback:<yaml[sc_tw].read[messages.badmenu]||<script[sc_tw_defaults].yaml_key[messages.badmenu]||&cError>>
          - else:
            - define placeholder:<yaml[sc_common].read[messages.admin.args_i]||<script[sc_common_defaults].yaml_key[messages.admin.args_i]||&cError>>
            - define feedback:<[placeholder].replace[[args]].with[<context.args.get[1]>]>
        - else:
          - if <context.args.get[1].to_lowercase.matches[open]>:
            - define icon:<context.args.get[3]>
            - if <[tabs].contains[<[selector]>]||false>:
              - define perms:!|:<yaml[sc_tw].read[tabs.<[selector]>.items.<[icon]>.permissions]||<list[]>>
              - foreach <[perms]>:
                - if <player.has_permission[<[value]>]||false> || <player.has_permission[<[admin]>]> || <player.is_op||false>:
                  - define ok:true
                  - foreach stop
              - if <[ok]||false>:
                - if <context.args.size.is[MORE].than[3]||false>:
                  - define placeholder:<yaml[sc_common].read[messages.admin.args_i]||<script[sc_common_defaults].yaml_key[messages.admin.args_i]||&cError>>
                  - define feedback:<[placeholder].replace[[args]].with[<context.args.remove[1|2|3].separated_by[, ]>]>
                - define path:!|:tabs|<[selector]>|items|<[icon]>
                - define keys:<yaml[sc_tw].list_keys[<[path].separated_by[.]>]>
                - inject <script[sc_tw_execute]> path:<[path].separated_by[.]>.script
              - else:
                - define feedback:<yaml[sc_common].read[messages.permission]||<script[sc_common_defaults].yaml_key[messages.permission]||&cError>>
    - else:
      - define feedback:<yaml[sc_common].read[messages.permission]||<script[sc_common_defaults].yaml_key[messages.permission]||&cError>>
      - if <[feedback].exists>:
        - inject <script[<yaml[sc_tw].read[scripts.narrator]||<script[sc_tw_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
#TO DO: Add support for sub-menu items
#TO DO: Add support for line-break items
sc_tw_menu:
    type: inventory
    debug: false
    title: <yaml[sc_tw].read[tabs.<yaml[sc_pcache].read[<player.uuid>.sc_tw.selector]>.title].unescaped.parse_color||<&c>Error>
    size: <element[<yaml[sc_tw].read[settings.rows]||<script[sc_tw_defaults].yaml_key[settings.rows]||2>>].add[2].mul[9].min[54].max[27]>
    procedural items:
    - define selector:<yaml[sc_pcache].read[<player.uuid>.sc_tw.selector]||<yaml[sc_tw].read[settings.default]||<script[sc_tw_defaults].yaml_key[settings.default]||options>>>
    - define index:<yaml[sc_pcache].read[<player.uuid>.sc_tw.index]||1>
    - define slots:<element[<yaml[sc_tw].read[settings.rows]||<script[sc_tw_defaults].yaml_key[settings.rows]||2>>].round_down.mul[9].min[36].max[9]>
    - define items:<yaml[sc_tw].list_keys[tabs.<[selector]>.items].alphanumeric>
    - define range:<[items].get[<[index]>].to[<[index].add[<[slots]>].sub[1]>]>
    - foreach <[range]||<list[]>> as:node:
      - define perms:!|:<yaml[sc_tw].read[tabs.<[selector]>.items.<[node]>.permissions]||<list[]>>
      - foreach <[perms]>:
        - if <player.has_permission[<[value]>]||false>:
          - define material:<yaml[sc_tw].read[tabs.<[selector]>.items.<[node]>.icon]||air>
          - define display:<yaml[sc_tw].read[tabs.<[selector]>.items.<[node]>.display].parsed||&cError>
          - define lore:<yaml[sc_tw].read[tabs.<[selector]>.items.<[node]>.lore].parsed||<list[]>>
          - define icon:<item[<[material]>].with[display_name=<[display]>;lore=<[lore]>;nbt=type/icon|data/<[node]>;flags=HIDE_ENCHANTS|HIDE_ATTRIBUTES]||<item[air]>>
          - if <yaml[sc_tw].read[tabs.<[selector]>.items.<[node]>.glow].parsed||false>:
            - adjust def:icon enchantments:protection,1
          - define icons:|:<[icon]>
          - foreach stop
    - repeat <[slots].sub[<[range].size>]>:
      - define icons:|:<item[air]>
    - define divider:<yaml[sc_tw].read[settings.divider]||<script[sc_tw_defaults].yaml_key[settings.divider]||iron_bars>>
    - repeat 9:
      - define icons:|:<item[<[divider]>].with[display_name=&sp]>
    - if <[index].is[MORE].than[1]||false>:
      - define prev:<item[spectral_arrow].with[display_name=&aPrev&spPage;nbt=type/prev|data/<[index].sub[<[slots]>]>]>
    - else:
      - define prev:<item[arrow].with[display_name=&7End&spof&splist;nbt=type/null|data/<[index]>]>
    - define icons:|:<[prev]>
    - define buttons:<yaml[sc_tw].list_keys[tabs].alphanumeric||<script[sc_tw_defaults].list_keys[tabs].alphanumeric||<list[]>>>
    - define active:<yaml[sc_pcache].read[<player.uuid>.sc_tw.selector]||<yaml[sc_tw].read[settings.default]||<script[sc_tw_defaults].yaml_key[setting.default]||options>>>
    - define tabindex:<[buttons].find[<[active]>]||1>
    - define offset:<[tabindex].min[<[buttons].size.sub[3]>].sub[<[buttons].size.min[4]>].max[0]>
    - define buttons:!|:<[buttons].get[<[offset].add[1]||1>].to[<[offset].add[7]||7>]>
    - foreach <[buttons]>:
      - define icon:<yaml[sc_tw].read[tabs.<[value]>.icon]||barrier>
      - define display:<yaml[sc_tw].read[tabs.<[value]>.display]||&cError>
      - define lore:<yaml[sc_tw].read[tabs.<[value]>.lore]||<list[&cYour&sptabs&spare&spnot|&ccorrectly&spconfigured.].unescaped.parse_color>>
      - define button:<item[<[icon]>].with[display_name=<[display]>;lore=<[lore]>;nbt=type/tab|data/<[value]>;flags=HIDE_ENCHANTS|HIDE_ATTRIBUTES|HIDE_POTION_EFFECTS]>
      - if <[value].matches[<[active]>]||false>:
        - adjust def:button enchantments:protection,1
      - define tabs:|:<[button]>
    - define icons:|:<[tabs].pad_right[7].with[<item[air]>]>
    - if <[items].size.is[MORE].than[<[index].add[<[slots]>]>]||false>:
      - define next:<item[spectral_arrow].with[display_name=&aNext&spPage;nbt=type/next|data/<[index].add[<[slots]>]>]>
    - else:
      - define next:<item[arrow].with[display_name=&7End&spof&splist;nbt=type/null|data/<[index]>]>
    - define icons:|:<[next]>
    - determine <[icons].unescaped.parse_color>
#TO DO: Read list position of subkeys and parse code execution in order specified
sc_tw_listener:
    type: world
    debug: false
    events:
        on reload scripts:
        - if <server.has_file[../Smellycraft/TabWorks.yml].not>:
          - inject <script[sc_tw_init]>
        on server start priority:1:
        - inject <script[sc_tw_init]>
        on shutdown:
        - define namespace:sc_tw
        - yaml set tabs:! id:sc_tw
        - inject <script[sc_common_save]>
        on delta time hourly:
        - define namespace:sc_tw
        - define silent:true
        - inject <script[sc_common_save]>
        - if <yaml[sc_tw].read[settings.update].to_lowercase.matches[true|enabled]||false>:
          - inject <script[<script[sc_tw_data].yaml_key[scripts.update]||sc_common_update>]>
        on player receives commands:
        - if <context.commands.contains_any[tabworks.firstrun|tabworks.firstran]>:
          - determine <context.commands.exclude[tabworks.firstrun|tabworks.firstran]>
        on player clicks in sc_tw_menu:
        - determine passively cancelled
        - define namespace:sc_tw
        - define type:<context.item.nbt[type]||null>
        - if <[type].matches[null]||false>:
          - stop
        - else if <[type].matches[prev|next]||null>:
          - define index:<context.item.nbt[data]>
          - yaml set <player.uuid>.sc_tw.index:<[index]> id:sc_pcache
        - else if <[type].matches[tab]||null>:
          - yaml set <player.uuid>.sc_tw.index:1 id:sc_pcache
          - yaml set <player.uuid>.sc_tw.selector:<context.item.nbt[data]> id:sc_pcache
        - else:
          - define selector:<yaml[sc_pcache].read[<player.uuid>.sc_tw.selector]||null>
          - define path:!|:tabs|<[selector]>|items|<context.item.nbt[data]>
          - define stay:<yaml[sc_tw].read[<[path].separated_by[.]>.stay]||true>
          - define keys:<yaml[sc_tw].list_keys[<[path].separated_by[.]>]>
          - inject <script[sc_tw_execute]>
        - inventory open d:<inventory[sc_tw_menu]>
        on player drags in sc_tw_menu:
        - determine cancelled
sc_tw_execute:
    type: task
    debug: false
    definitions: keys|path
    script:
    - if <[keys].contains[script]>:
      - inject <script[<yaml[sc_tw].read[<[path].get[1|2].separated_by[.]>.scriptname]>]> path:<[path].separated_by[.]>.script
    - if <[keys].contains[scommand]>:
      - foreach <yaml[sc_tw].read[<[path].separated_by[.]>.scommand].replace[%p].with[<player.name>]>:
        - execute as_server '<[value].parsed>'
    - if <[keys].contains[pcommand]>:
      - foreach <yaml[sc_tw].read[<[path].separated_by[.]>.pcommand]>:
        - execute as_player '<[value].parsed>'
    - if <yaml[sc_tw].read[<[path].separated_by[.]>.stay]||true>:
      - inventory open d:<inventory[sc_tw_menu]>
      - if <[keys].contains[message]>:
        - define title:<yaml[sc_tw].read[<[path].separated_by[.]>.message].parsed||&cError>
        - inject <script[<yaml[sc_tw].read[scripts.GUI]||<script[sc_tw_defaults].yaml_key[scripts.GUI]||sc_common_marquee>>]>
    - else:
      - inventory close
      - if <[keys].contains[message]>:
        - define feedback:<yaml[sc_tw].read[<[path].separated_by[.]>.message].parsed||&cError>
        - inject <script[<yaml[sc_tw].read[scripts.narrator]||<script[sc_tw_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
      - stop
sc_tw_data:
    type: yaml data
    version: 1.2
    filename: tabworks.yml
    scripts:
      reload: sc_tw_init
      save: sc_common_save
      update: sc_common_update
sc_tw_defaults:
  type: yaml data
  settings:
    rows: 1
    divider: vine
    default: options
    update: true
  scripts:
    narrator: sc_common_feedback
    GUI: sc_common_marquee
  permissions:
    admin: tabworks.admin
    use: tabworks.use
  messages:
    prefix: '&9[&2Tab&aWorks&9]'
    reload: '&9Plugin has been reloaded.'
    description: 'Multidimensional GUI fit for almost any purpose.'
    missing_common: '&This plugin uses code contained in sc_common.yml.  Visit https://smellycraft.com/d/common for the most recent version.'
    missing_script: '&9 Script &a[script] &9was not detected. &c Installation not complete. &9An alternative is available in the Common Files.'
    args_i: '&9Unused arguments: &c[args]'
    badmenu:
    - '&cPlease select a choice from the provided list'
