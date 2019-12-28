###########################################
# Made by Smellyonionman for Smellycraft. #
#          onion@smellycraft.com          #
#    Tested on Denizen-1.1.1-b4492-DEV    #
#               Version 1.1               #
#-----------------------------------------#
#     Updates and notes are found at:     #
#   https://smellycraft.com/d/denizence   #
#-----------------------------------------#
#    You may use, modify or share this    #
#    script, provided you don't remove    #
#    or alter lines 1-13 of this file.    #
###########################################
#   This script requires PlaceholderAPI   #
###########################################
sc_dce_init:
    type: task
    debug: false
    script:
    - define namespace:sc_dce
    - define targets:<server.list_online_players.filter[has_permission[residence.admin]]||<player>>
    - if <server.has_file[../Smellycraft/denizence.yml]||false>:
      - ~yaml load:../Smellycraft/denizence.yml id:sc_dce
    - else:
      - ~yaml create id:sc_dce
      - define payload:<script[sc_dce_defaults].to_json||null>
      - if <[payload].matches[null]>:
        - ~webget https://raw.githubusercontent.com/smellyonionman/smellycraft/master/configs/denizence.yml save:sc_raw headers:host/smellycraft.com:443|user-agent/smellycraft
        - define payload:<entry[sc_raw].result>
      - ~yaml loadtext:<[payload]> id:sc_dce
      - yaml set type:! id:sc_dce
    - foreach <yaml[sc_dce].list_keys[scripts]||<script[sc_dce_defaults].list_keys[scripts]||<list[]>>> as:task:
      - if <server.object_is_valid[<script[<yaml[sc_dce].read[scripts.<[task]>]||<script[sc_dce_defaults].yaml_key[scripts.<[task]>]>>]>].not>:
        - define placeholder:<yaml[sc_dce].read[messages.missing_script]||<script[sc_dce_defaults].yaml_key[messages.missing_script]||&cError>>
        - narrate '<[placeholder].replace[[script]].with[<[task]>].separated_by[&sp].unescaped.parse_color>'
        - stop
      - ~yaml loadtext:../plugins/Residence/config.yml id:sc_dce_resconf
      - yaml set gui.current.material.create:<yaml[sc_dce_resconf].read[Global.SelectionToolId]||wooden_axe> id:sc_dce
      - ~yaml unload id:sc_dce_resconf
      - ~yaml savefile:../Smellycraft/denizence.yml id:sc_dce
      - yaml set version:1.1 id:sc_dce
      - define feedback:<yaml[sc_dce].read[messages.reload]||<script[sc_dce_defaults].yaml_key[messages.reload]||&cError>>
    - inject <script[<yaml[sc_dce].read[scripts.narrator]||<script[sc_dce_defaults].yaml_key[scripts.narrator]>>]>
sc_dce_cmd:
    type: command
    debug: false
    name: denizence
    description: <yaml[sc_dce].read[messages.description]||GUI for Residence Users>
    usage: /denizence
    script:
    - define namespace:sc_dce
    - define admin:<yaml[sc_dce].read[permissions.admin]||<script[sc_dce_defaults].yaml_key[permissions.admin]>>
    - if <context.args.size.is[==].to[0]||false>:
      - if <player.has_permission[<yaml[sc_dce].read[permissions.use]||<script[sc_dce_defaults].yaml_key[permissions.use]>>]>:
        - inventory open d:<inventory[sc_dce_menu]>
      - else:
        - define feedback:<yaml[sc_common].read[messages.permission]||<script[sc_dce_defaults].yaml_key[messages.permission]&cError>>
    - else:
      - if <context.args.get[1].to_lowercase.matches[(save|update|reload)]||false>:
        - define filename:denizence.yml
        - inject <script[sc_common_datacmd]>
      - else if <context.args.get[1].to_lowercase.matches[credits]||false>:
        - define feedback:'&2Denizence &9made by your friend &6smellyonionman&nl&9Go to &ahttps&co//smellycraft.com/denizence &9for info.'
      - if <context.args.size.is[MORE].than[1]>:
        - define placeholder:<yaml[sc_common].read[messages.admin.args_i]||<script[sc_common_defaults].yaml_key[messages.admin.args_i]||&cError>>
        - define feedback:<[placeholder].replace[[args]].with[<context.args.get[1]>
    - if <[feedback].exists>:
      - inject <script[<yaml[sc_dce].read[scripts.narrator]||<script[sc_dce_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
sc_dce_menu:
    type: inventory
    debug: false
    title: <element[<yaml[sc_dce].read[gui.marquee.default]||<script[sc_dce_defaults].yaml_key[gui.marquee.default]>>].unescaped.parse_color>
    size: 18
    definitions:
      Current: <proc[sc_dce_menu_current]>
      Messages: <proc[sc_dce_menu_msgs]>
      Flags: <proc[sc_dce_menu_flags]>
      Size: <proc[sc_dce_menu_size]>
      Subzones: <proc[sc_dce_menu_zones]>
      Rental: <proc[sc_dce_menu_rent]>
      Back: <proc[sc_back_display]>
    slots:
    - "[Current] [] [] [] [Messages] [Flags] [Size] [Subzones] [Rental]"
    - "[Back] [] [] [] [] [] [] [] []"
sc_dce_menu_current:
    type: procedure
    debug: false
    script:
    - define name:<placeholder[residence_user_current_res].before[.].to_titlecase||null>
    #Are you in a residence? If not, determine create button.  If so...
    - if <[name].matches[].not>:
      - define owner:<placeholder[residence_user_current_owner]||null>
      - define size:<placeholder[residence_user_current_qsize]||null>
      - define subzone:<placeholder[residence_user_current_res].after_last[.].to_titlecase||null>
      #Are you the owner? If so, details.
      - if <[owner].matches[<player.name>]>:
        - define button:<item[<yaml[sc_dce].read[gui.current.material.owned]||<script[sc_dce_defaults].yaml_key[gui.current.material.owned]||oak_door>>].with[display_name=<yaml[sc_dce].read[gui.current.display.owned]||<script[sc_dce_defaults].yaml_key[gui.current.display.owned]||&aWelcome&spHome>>;nbt=click/owned]>
        - define placeholder:<yaml[sc_dce].read[gui.current.lore.name]||<script[sc_dce_defaults].yaml_key[gui.current.lore.name]>>
        - define lore:!|:<[placeholder].replace[[name]].with[<[name]||&cError>]>
        - define lore:|:<yaml[sc_dce].read[gui.current.lore.owned]||<script[sc_dce_defaults].yaml_key[gui.current.lore.owned]>>
        - define placeholder:<yaml[sc_dce].read[gui.current.lore.size]||<script[sc_dce_defaults].yaml_key[gui.current.lore.size]>>
        - define lore:|:<[placeholder].replace[[size]].with[<[size]||&cError>]>
        - define placeholder:<yaml[sc_dce].read[gui.current.lore.subzone]||<script[sc_dce_defaults].yaml_key[gui.current.lore.subzone]>>
        - define lore:|:<[placeholder].replace[[subzone]].with[<tern[<[subzone].matches[].not>].pass[<[subzone]>].fail[&f&oNone]>]>
        - define lore:|:<yaml[sc_dce].read[gui.current.lore.remove]||<script[sc_dce_defaults].yaml_key[gui.current.lore.remove]>>
      #If someone else owns this residence...
      - else:
        - define button:<item[<yaml[sc_dce].read[gui.current.material.not_owned]||<script[sc_dce_defaults].yaml_key[gui.current.material.not_owned]||iron_door>>].with[display_name=<yaml[sc_dce].read[gui.current.display.not_owned]||<script[sc_dce_defaults].yaml_key[gui.current.display.not_owned]||&cClaimed&spLand>>;nbt=click/notowned]>
        - define placeholder:<yaml[sc_dce].read[gui.current.lore.not_owned]||<script[sc_dce_defaults].yaml_key[gui.current.lore.not_owned]>>
        - define lore:!|:<[placeholder].replace[[owner]].with[<[owner]>].replace[[name]].with[<[name]>]>
        - define placeholder:<yaml[sc_dce].read[gui.current.lore.subzone]||<script[sc_dce_defaults].yaml_key[gui.current.lore.subzone]>>
        - define lore:|:<[placeholder].replace[[subzone]].with[<tern[<[subzone].matches[].not>].pass[<[subzone]>].fail[&f&oNone]>]>
        #Is it for rent or for sale? If for rent...
        - define forrent:<placeholder[residence_user_current_forrent]||null>
        - define renter:<placeholder[residence_user_current_rentedby]||null>
        - define renewdate:<placeholder[residence_user_current_rentends]||null>
        - define rentprice:<placeholder[residence_user_current_rentprice]||null>
        - define rentperiod:<placeholder[residence_user_current_rentdays]||null>
        - if <[forrent]>:
          #Are you the tenant? Click for more buttons. or...
          - if <[renter].matches[<player.name>]>:
            - define button:<item[<yaml[sc_dce].read[gui.market.material.rented]||<script[sc_dce_defaults].yaml_key[gui.market.material.rented]||tripwire_hook>>].with[display_name=<yaml[sc_dce].read[gui.market.display.rented]||<script[sc_dce_defaults].yaml_key[gui.market.display.rented]||&aCurrently&spRenting>>;nbt=click/rented;enchantments=protection,1;flags=HIDE_ENCHANTS]>
            - define placeholder:<yaml[sc_dce].read[gui.market.lore.due]||<script[sc_dce_defaults].yaml_key[gui.market.lore.due]>>
            - define lore:|:<[placeholder].replace[[renewdate]].with[<[renewdate]>]>
            - define placeholder:<yaml[sc_dce].read[gui.market.lore.cost]||<script[sc_dce_defaults].yaml_key[gui.market.lore.cost]>>
            - define lore:|:<[placeholder].replace[[rentprice]].with[<server.economy.format[<[rentprice]>]>]>
            - define lore:|:<yaml[sc_dce].read[gui.current.lore.rent_unrent]||<script[sc_dce_defaults].yaml_key[gui.current.lore.rent_unrent]>>
          #Is another the tenant? or...
          - else if <[renter].matches[].not>:
            - define placeholder:<yaml[sc_dce].read[gui.market.lore.tenant]||<script[sc_dce_defaults].yaml_key[gui.market.lore.tenant]>>
            - define lore:|:<[placeholder].replace[[renter]].with[<[renter]>]>
          #Is the place rentable by you?
          - else:
            - define button:<item[<yaml[sc_dce].read[gui.market.material.forrent]||<script[sc_dce_defaults].yaml_key[gui.market.material.forrent]||tripwire_hook>>].with[display_name=<yaml[sc_dce].read[gui.market.display.forrent]||<script[sc_dce_defaults].yaml_key[gui.market.display.forrent]||&aSpace&spfor&spRent>>;nbt=click/forrent]>
            - define placeholder:<yaml[sc_dce].read[gui.current.lore.rent_vacant]||<script[sc_dce_defaults].yaml_key[gui.current.lore.rent_vacant]>>
            - define lore:|:<[placeholder].replace[[rentprice]].with[<server.economy.format[<[rentprice]>]>
            - define placeholder:<yaml[sc_dce].read[gui.current.lore.rent_period]||<script[sc_dce_defaults].yaml_key[gui.current.lore.rent_period]>>
            - define lore:|:<[placeholder].replace[[rentperiod]].with[<[rentperiod]>]>
            - define lore:|:<yaml[sc_dce].read[gui.current.lore.newrent]||<script[sc_dce_defaults].yaml_key[gui.current.lore.newrent]>>
        #...or is it for sale? If so... details.  If not, nothing.
        - define forsale:<placeholder[residence_user_current_forsale]||null>
        - define saleprice:<placeholder[residence_user_current_saleprice]||null>
        - else if <[forsale]>:
          - define button:<item[<yaml[sc_dce].read[gui.market.material.forsale]||<script[sc_dce_defaults].yaml_key[gui.market.material.forsale]||oak_sign>>].with[display_name=<yaml[sc_dce].read[gui.market.display.forsale]||<script[sc_dce_defaults].yaml_key[gui.market.display.forsale]||&aFor&spSale>>]>
          - define lore:|:<yaml[sc_dce].read[gui.current.lore.forsale]||<script[sc_dce_defaults].yaml_key[gui.current.lore.forsale]>>
          - define placeholder:|:<yaml[sc_dce].read[gui.current.lore.saleprice]||<script[sc_dce_defaults].yaml_key[gui.current.lore.saleprice]>>
          - define lore:|:<[placeholder].replace[[saleprice]].with[<server.economy.format[<[saleprice]>]>]>
    #If there is no residence here...
    - else:
      - define button:<item[<yaml[sc_dce].read[gui.market.material.forsale]||<script[sc_dce_defaults].yaml_key[gui.market.material.forsale]||oak_sign>>].with[display_name=<yaml[sc_dce].read[gui.market.display.forsale]||<script[sc_dce_defaults].yaml_key[gui.market.display.forsale]||&aFor&spSale>>;nbt=click/forsale]>
      - define lore:!|:<yaml[sc_dce].read[gui.current.lore.create]||<script[sc_dce_defaults].yaml_key[gui.current.lore.create]>>
      - define lore:<[button].lore.exclude[<[button].lore.last>].include[<[lore]>]>
      - adjust def:button display_name:<yaml[sc_dce].read[gui.current.display.create]||<script[sc_dce_defaults].yaml_key[gui.current.display.create]>>
    - adjust def:button lore:<[lore]||null>
    - determine <[button].unescaped.parse_color||null>
sc_dce_menu_flags:
    type: procedure
    debug: false
    script:
    - define name:<placeholder[residence_user_current_res].before[.].to_titlecase||null>
    #Are you in a residence? If not, determine empty.
    - if <[name].matches[].not>:
      - define owner:<placeholder[residence_user_current_owner]||null>
      - define subzone:<placeholder[residence_user_current_res].after_last[.].to_titlecase||null>
      #Are you the owner? If so, details. Click for more buttons.
      - if <[owner].matches[<player.name>]>:
        - define button:<item[<yaml[sc_dce].read[gui.flags.material]||<script[sc_dce_defaults].yaml_key[gui.flags.material]||white_banner>>].with[display_name=<yaml[sc_dce].read[gui.flags.display]||<script[sc_dce_defaults].yaml_key[gui.flags.display]||&aAdjust&spFlags>>;nbt=click/flags]>
        - define lore:!|:<yaml[sc_dce].read[gui.flags.lore.set_global]||<script[sc_dce_defaults].yaml_key[gui.flags.lore.set_player]>>
        - define lore:|:<yaml[sc_dce].read[gui.flags.lore.set_player]||<script[sc_dce_defaults].yaml_key[gui.flags.lore.set_global]>>
        - define placeholder:<yaml[sc_dce].read[gui.flags.lore.editing_zone]||<script[sc_dce_defaults].yaml_key[gui.flags.lore.editing_zone]>>
        - define lore:|:<[placeholder].replace[[subzone]].with[<tern[<[subzone].matches[].not>].pass[<[subzone]>].fail[&f&oNone]>]>
      #If someone else owns this residence...
      - else:
        #Is it for rent or for sale? If for rent...
        - define forrent:<placeholder[residence_user_current_forrent]||null>
        - define renter:<placeholder[residence_user_current_rentedby]||null>
        - if <[forrent]>:
          #Are you the tenant? Click for more buttons. or...
          - if <[renter].matches[<player.name>]>:
            - define button:<item[<yaml[sc_dce].read[gui.flags.material]||<script[sc_dce_defaults].yaml_key[gui.flags.material]||white_banner>>].with[display_name=<yaml[sc_dce].read[gui.flags.display]||<script[sc_dce_defaults].yaml_key[gui.flags.display]||&aAdjust&spFlags>>;nbt=click/flags]>
            - define lore:!|:<yaml[sc_dce].read[gui.flags.lore.set_global]||<script[sc_dce_defaults].yaml_key[gui.flags.lore.set_player]>>
            - define lore:|:<yaml[sc_dce].read[gui.flags.lore.set_player]||<script[sc_dce_defaults].yaml_key[gui.flags.lore.set_global]>>
    #If there is no residence here...
    - else:
      - define button:<item[air]>
    - adjust def:button lore:<[lore]||null>
    - determine <[button].unescaped.parse_color||null>
sc_dce_menu_msgs:
    type: procedure
    debug: false
    script:
    - define name:<placeholder[residence_user_current_res].before[.].to_titlecase||null>
    #Are you in a residence? If not, determine empty.
    - if <[name].matches[].not>:
      - define owner:<placeholder[residence_user_current_owner]||null>
      - define subzone:<placeholder[residence_user_current_res].after_last[.].to_titlecase||null>
      #Are you the owner? If so, details.
      - if <[owner].matches[<player.name>]>:
        - define button <item[<yaml[sc_dce].read[gui.messages.material]||<script[sc_dce_defaults].yaml_key[gui.messages.material]||name_tag>>].with[display_name=<yaml[sc_dce].read[gui.messages.display]||<script[sc_dce_defaults].yaml_key[gui.messages.display]||&aChange&spMessages>>;nbt=click/msgs]>
        - define lore:!|:<yaml[sc_dce].read[gui.messages.lore.header]||<script[sc_dce_defaults].yaml_key[gui.messages.lore.header]>>
        - define lore:|:<yaml[sc_dce].read[gui.messages.lore.buttons_1]||<script[sc_dce_defaults].yaml_key[gui.messages.lore.buttons_1]>>
        - define lore:|:<yaml[sc_dce].read[gui.messages.lore.buttons_2]||<script[sc_dce_defaults].yaml_key[gui.messages.lore.buttons_2]>>
        - define placeholder:<yaml[sc_dce].read[gui.messages.lore.editing_zone]||<script[sc_dce_defaults].yaml_key[gui.messages.lore.editing_zone]>>
        - define lore:|:<[placeholder].replace[[subzone]].with[<tern[<[subzone].matches[].not>].pass[<[subzone]>].fail[&f&oNone]>]>
      #If someone else owns this residence...
      - else:
        #Is it for rent or for sale? If for rent...
        - define forrent:<placeholder[residence_user_current_forrent]||null>
        - define renter:<placeholder[residence_user_current_rentedby]||null>
        - if <[forrent]>:
          #Are you the tenant? Click for more buttons. or...
          - if <[renter].matches[<player.name>]>:
            - define lore:!|:<yaml[sc_dce].read[gui.messages.lore.header]||<script[sc_dce_defaults].yaml_key[gui.messages.lore.header]>>
            - define lore:|:<yaml[sc_dce].read[gui.messages.lore.buttons_1]||<script[sc_dce_defaults].yaml_key[gui.messages.lore.buttons_1]>>
            - define lore:|:<yaml[sc_dce].read[gui.messages.lore.buttons_2]||<script[sc_dce_defaults].yaml_key[gui.messages.lore.buttons_2]>>
    #If there is no residence here...
    - else:
      - define button:<item[air]>
    - adjust def:button lore:<[lore]||null>
    - determine <[button].unescaped.parse_color||null>
sc_dce_menu_size:
    type: procedure
    debug: false
    script:
    - define name:<placeholder[residence_user_current_res].before[.].to_titlecase||null>
    #Are you in a residence? If not, determine nothing.  If so...
    - if <[name].matches[].not>:
      - define owner:<placeholder[residence_user_current_owner]||null>
      - define subzone:<placeholder[residence_user_current_res].after_last[.].to_titlecase||null>
      #Are you the owner? If so, details.
      - if <[owner].matches[<player.name>]>:
        - define button:<item[<yaml[sc_dce].read[gui.size.material]||<script[sc_dce_defaults].yaml_key[gui.size.material]||stick>>].with[display_name=<yaml[sc_dce].read[gui.size.display]||<script[sc_dce_defaults].yaml_key[gui.size.display]||&aExpand&spor&spContract>>;nbt=click/size]>
        - define maxew:<placeholder[residence_user_maxew]||0>
        - define maxns:<placeholder[residence_user_maxns]||0>
        - define maxud:<placeholder[residence_user_maxud]||0>
        - define lore:!|:<yaml[sc_dce].read[gui.size.lore.header]||<script[sc_dce_defaults].yaml_key[gui.size.lore.header]>>
        - define lore:|:<yaml[sc_dce].read[gui.size.lore.buttons]||<script[sc_dce_defaults].yaml_key[gui.size.lore.buttons]>>
        - define lore:|:<yaml[sc_dce].read[gui.size.lore.limits_1]||<script[sc_dce_defaults].yaml_key[gui.size.lore.limits_1]>>
        - define placeholder:<yaml[sc_dce].read[gui.size.lore.limits_2]||<script[sc_dce_defaults].yaml_key[gui.size.lore.limits_2]>>
        - define lore:|:<[placeholder].replace[[maxew]].with[<[maxew]>].replace[[maxud]].with[<[maxud]>].replace[[maxns]].with[<[maxns]>]>
        - define placeholder:<yaml[sc_dce].read[gui.size.lore.editing_zone]||<script[sc_dce_defaults].yaml_key[gui.size.lore.editing_zone]>>
        - define lore:|:<[placeholder].replace[[subzone]].with[<tern[<[subzone].matches[].not>].pass[<[subzone]>].fail[&f&oNone]>]>
    #If there is no residence here...
    - else:
      - define button:<item[air]>
    - adjust def:button lore:<[lore]||null>
    - determine <[button].unescaped.parse_color||null>
sc_dce_menu_zones:
    type: procedure
    debug: false
    script:
    - define name:<placeholder[residence_user_current_res].before[.].to_titlecase||null>
    #Are you in a residence? If not, determine nothing.  If so...
    - if <[name].matches[].not>:
      - define owner:<placeholder[residence_user_current_owner]||null>
      - define subzone:<placeholder[residence_user_current_res].after_last[.].to_titlecase||null>
      #Are you the owner? If so, details.
      - if <[owner].matches[<player.name>]>:
        - define button:<item[<yaml[sc_dce].read[gui.zones.material]||<script[sc_dce_defaults].yaml_key[gui.zones.material]||oak_fence>>].with[display_name=<yaml[sc_dce].read[gui.zones.display]||<script[sc_dce_defaults].yaml_key[gui.zones.display]||&aManage&spSubzones>>;nbt=click/zones]>
        - define lore:!|:<yaml[sc_dce].read[gui.zones.lore.header]||<script[sc_dce_defaults].yaml_key[gui.zones.lore.header]>>
        - define lore:|:<yaml[sc_dce].read[gui.zones.lore.buttons]||<script[sc_dce_defaults].yaml_key[gui.zones.lore.buttons]>>
        - define placeholder:<yaml[sc_dce].read[gui.zones.lore.editing_zone]||<script[sc_dce_defaults].yaml_key[gui.zones.lore.editing_zone]>>
        - define lore:|:<[placeholder].replace[[subzone]].with[<tern[<[subzone].matches[].not>].pass[<[subzone]>].fail[&f&oNone]>]>
    #If there is no residence here...
    - else:
      - define button:<item[air]>
    - adjust def:button lore:<[lore]||null>
    - determine <[button].unescaped.parse_color||null>
sc_dce_menu_rent:
    type: procedure
    debug: false
    script:
    - define name:<placeholder[residence_user_current_res].before[.].to_titlecase||null>
    #Are you in a residence? If not, determine create button.  If so...
    - if <[name].length.is[MORE].than[0]>:
      - define owner:<placeholder[residence_user_current_owner]||null>
      #Are you the owner? If so, continue.
      - if <[owner].matches[<player.name>]>:
        - define subzone:<placeholder[residence_user_current_res].after_last[.].to_titlecase||null>
        - define placeholder:<yaml[sc_dce].read[gui.market.lore.editing_zone]||<script[sc_dce_defaults].yaml_key[gui.market.lore.editing_zone]>>
        - define lore:|:<[placeholder].replace[[subzone]].with[<tern[<[subzone].matches[].not>].pass[<[subzone]>].fail[&f&oNone]>]>
        #Is it for rent or for sale? If for rent...
        - define forrent:<placeholder[residence_user_current_forrent]||null>
        - if <[forrent]>:
          - define button:<item[<yaml[sc_dce].read[gui.market.material.unlist]||<script[sc_dce_defaults].yaml_key[gui.market.material.unlist]||tripwire_hook>>].with[display_name=<yaml[sc_dce].read[gui.market.display.unlist]||<script[sc_dce_defaults].yaml_key[gui.market.display.unlist]||&aRemove&spfrom&spMarket>>;nbt=click/unrent]>
          - define renter:<placeholder[residence_user_current_rentedby]||null>
          #Is a tenant currently occupying? or...
          - if <[renter].matches[].not>:
            - define renewdate:<placeholder[residence_user_current_rentends]||null>
            - define rentprice:<placeholder[residence_user_current_rentprice]||null>
            - define rentperiod:<placeholder[residence_user_current_rentdays]||null>
            - define placeholder:<yaml[sc_dce].read[gui.market.lore.tenant]||<script[sc_dce_defaults].yaml_key[gui.market.lore.tenant]>>
            - define lore:|:<[placeholder].replace[[renter]].with[<[renter]>]>
            - define placeholder:<yaml[sc_dce].read[gui.market.lore.due]||<script[sc_dce_defaults].yaml_key[gui.market.lore.due]>>
            - define placeholder:<yaml[sc_dce].read[gui.market.lore.cost]||<script[sc_dce_defaults].yaml_key[gui.market.lore.cost]>>
            - define lore:|:<[placeholder].replace[[rentprice]].with[<server.economy.format[<[rentprice]>]>]>
            - define lore:|:<yaml[sc_dce].read[gui.market.lore.evict]||<script[sc_dce_defaults].yaml_key[gui.market.lore.evict]>>
          - else:
            - define lore:|:<yaml[sc_dce].read[gui.market.lore.vacant]||<script[sc_dce_defaults].yaml_key[gui.market.lore.vacant]>>
            - define lore:|:<yaml[sc_dce].read[gui.market.lore.unlist]||<script[sc_dce_defaults].yaml_key[gui.market.lore.unlist]>>
        - else:
          - define button:<item[<yaml[sc_dce].read[gui.market.material.list]||<script[sc_dce_defaults].yaml_key[gui.market.material.list]||tripwire_hook>>].with[display_name=<yaml[sc_dce].read[gui.market.display.list]||<script[sc_dce_defaults].yaml_key[gui.market.display.list]||&aMake&spRentable>>;nbt=click/rent]>
          - define lore:|:<yaml[sc_dce].read[gui.market.lore.list]||<script[sc_dce_defaults].yaml_key[gui.market.lore.list]>>
    #If there is no residence here...
    - else:
      - define button:<item[air]>
    - adjust def:button lore:<[lore]||null>
    - determine <[button].unescaped.parse_color||null>
sc_dce_listener:
    type: world
    debug: false
    events:
        on reload scripts:
        - if <server.has_file[../Smellycraft/denizence.yml].not||false>:
          - inject <script[sc_dce_init]>
        on server start:
        - inject <script[sc_dce_init]>
        on delta time hourly:
        - define namespace:sc_dce
        - define filename:denizence.yml
        - inject <script[sc_common_save]>
        - if <yaml[sc_dce].read[settings.update].to_lowercase.matches[true|enabled]||false>:
          - inject <script[<yaml[sc_dce].read[scripts.update]||<script[sc_dce_defaults].yaml_key[scripts.update]||sc_common_update>>]>
        on shutdown:
        - ~yaml savefile:../Smellycraft/denizence.yml id:sc_dce
        - yaml unload id:sc_dce
        on player opens sc_dce_menu:
        - define namespace:sc_dce
        - if <player.has_permission[<yaml[sc_dce].read[permissions.use]||<script[sc_dce_defaults].yaml_key[permissions.use]||residence.gui>>].not>:
          - determine passively cancelled
          - define feedback:<yaml[sc_common].read[messages.permission]||<script[sc_common].yaml_key[messages.permission]||&cError>>
          - inject <script[<yaml[sc_dce].read[scripts.narrator]||<script[sc_dce_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
        on player drags in sc_dce_menu:
        - determine cancelled
        on player clicks in sc_dce_menu:
        - define namespace:sc_dce
        - determine passively cancelled
        - define click:<context.item.nbt[click]||null>
        - if <[click].matches[null]||false>:
          - stop
        - choose <context.item.nbt[click]>:
          - case "owned":
            - inventory close
            - execute as_player "res remove <placeholder[residence_user_current_res]>"
          - case "renting":
            - inventory close
            - execute as_player "res market unrent"
          - case "forrent":
            - execute as_player "res market rent"
            - wait <duration[5t]>
            - inventory open d:<inventory[sc_dce_menu]>
          - case "forsale":
            - execute as_player "res market buy"
            - wait <duration[5t]>
            - inventory open d:<inventory[sc_dce_menu]>
          - case "create":
            - flag player sc_dce_input:res_create_name duration:<duration[1m]>
            - inventory close
            - wait <duration[20t]>
            - define feedback:<yaml[sc_dce].read[messages.enter_name]||<script[sc_dce_defaults].yaml_key[messages.enter_name]>>
          - case "size":
            - execute as_player "res select residence"
            - if <context.click.matches[LEFT]>:
              - execute as_player "res select expand 1"
              - inventory open d:<inventory[sc_dce_menu]>
            - else if <context.click.matches[RIGHT]>:
              - execute as_player "res select contract 1"
              - inventory open d:<inventory[sc_dce_menu]>
            - else:
              - define title:<yaml[sc_dce].read[gui.marquee.click_type]||<script[sc_dce_defaults].yaml_key[gui.marquee.click_type]>>
              - inject <script[<yaml[sc_dce].read[scripts.GUI]||<script[sc_dce_defaults].yaml_key[scripts.GUI]||sc_common_marquee>>]>
          - case "subzones":
            - if <context.click.matches[LEFT]>:
              - flag player sc_dce_input:res_subzone_name duration:<duration[1m]>
              - inventory close
              - wait <duration[20t]>
              - define feedback:<yaml[sc_dce].read[messages.enter_subzone]||<script[sc_dce_defaults].yaml_key[messages.enter_subzone]>>
            - else if <context.click.matches[RIGHT]>:
              - execute as_player "res remove"
          - case "flags":
            - if <context.click.matches[LEFT]>:
              - execute as_player "res set"
            - else if <context.click.matches[RIGHT]>:
              - flag player sc_dce_input:res_player_flags duration:<duration[1m]>
              - inventory close
              - wait <duration[20t]>
              - define feedback:<yaml[sc_dce].read[messages.enter_player]||<script[sc_dce_defaults].yaml_key[messages.enter_player]>>
          - case "msgs":
            - if <context.click.matches[LEFT]>:
              - flag player sc_dce_input:res_message_enter duration:<duration[1m]>
            - else if <context.click.matches[RIGHT]>:
              - flag player sc_dce_input:res_message_leave duration:<duration[1m]>
            - else if <context.click.matches[SHIFT_LEFT]>:
              - execute as_player "res message enter remove"
              - define placeholder:<yaml[sc_dce].read[gui.marquee.message_removed]||<script[sc_dce_defaults].yaml_key[gui.marquee.message_removed]||&cError>>
              - define title:<[placeholder].replace[[type]].with[enter]>
              - inject <script[<yaml[sc_dce].read[scripts.GUI]||<script[sc_dce_defaults].yaml_key[scripts.GUI]||sc_common_marquee>>]>
              - stop
            - else if <context.click.matches[SHIFT_RIGHT]>:
              - execute as_player "res message leave remove"
              - define placeholder:<yaml[sc_dce].read[gui.marquee.message_removed]||<script[sc_dce_defaults].yaml_key[gui.marquee.message_removed]||&cError>>
              - define title:<[placeholder].replace[[type]].with[leave]>
              - inject <script[<yaml[sc_dce].read[scripts.GUI]||<script[sc_dce_defaults].yaml_key[scripts.GUI]||sc_common_marquee>>]>
              - stop
            - inventory close
            - wait <duration[20t]>
            - define feedback:<yaml[sc_dce].read[messages.enter_message]||<script[sc_dce_defaults].yaml_key[messages.enter_message]||&cError>>
          - case "rent":
            - flag player sc_dce_input:!|:res_market_rent duration:1m
            - inventory close
            - wait <duration[20t]>
            - define feedback:<yaml[sc_dce].read[messages.enter_message]||<script[sc_dce_defaults].yaml_key[messages.enter_price]||&cError>>
          - case "unrent":
            - execute as_player "res market unrent"
            - wait <duration[5t]>
            - inventory open d:<inventory[sc_dce_menu]>
          - case "back":
            - inventory open d:<inventory[sc_main_menu]>
          - case "default":
            - stop
        - if <[feedback].exists>:
          - inject <script[<yaml[sc_dce].read[scripts.narrator]||<script[sc_dce_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
        on residence||res command:
            - if <context.args.get[1].matches[menu]||false>:
              - determine passively cancelled
              - inventory open d:<inventory[sc_dce_menu]>
        on player chats flagged:sc_dce_input:
        - define namespace:sc_dce
        - determine passively cancelled
        - if <player.flag[sc_dce_input].matches[res_create_name]>:
          - if <context.message.to_lowercase.matches[cancel]>:
            - define title:<yaml[sc_dce].read[gui.marquee.cancel_res]||<script[sc_dce_defaults].yaml_key[gui.marquee.cancel_res]>>
          - else:
            - execute as_player "res create <context.message>"
        - else if <player.flag[sc_dce_input].matches[res_subzone_name]>:
          - if <context.message.to_lowercase.matches[cancel]>:
            - define title:<yaml[sc_dce].read[gui.marquee.cancel_zone]||<script[sc_dce_defaults].yaml_key[gui.marquee.cancel_zone]>>
          - else:
            - execute as_player "res subzone <context.message>"
        - else if <player.flag[sc_dce_input].matches[res_message_enter]>:
          - if <context.message.to_lowercase.matches[cancel]>:
            - define placeholder:<yaml[sc_dce].read[gui.marquee.cancel_message]||<script[sc_dce_defaults].yaml_key[gui.marquee.cancel_message]>>
            - define title:<[placeholder].replace[[type]].swith[entry]>
          - else if <context.message.to_lowercase.matches[]>:
            - execute as_player "res message enter remove"
          - else:
            - execute as_player <element[res&spmessage&spenter&sp<context.message.escaped>].unescaped>
        - else if <player.flag[sc_dce_input].matches[res_message_leave]>:
          - if <context.message.to_lowercase.matches[cancel]>:
            - define placeholder:<yaml[sc_dce].read[gui.marquee.cancel_message]||<script[sc_dce_defaults].yaml_key[gui.marquee.cancel_message]>>
            - define title:<[placeholder].replace[[type]].with[entry]>
          - else if <context.message.to_lowercase.matches[]>:
            - execute as_player "res message enter remove"
          - else:
            - execute as_player "res message leave <context.message>"
        - else if <player.flag[sc_dce_input].matches[res_player_flags]>:
          - if <context.message.to_lowercase.matches[cancel]>:
            - define title:<yaml[sc_dce].read[gui.marquee.cancel_player]||<script[sc_dce_defaults].yaml_key[gui.marquee.cancel_player]>>
          - else:
            - execute as_player "res pset <placeholder[residence_user_current_res]> <context.message>"
            - flag player sc_dce_input:!
            - stop
        - else if <player.flag[sc_dce_input].get[1].matches[res_market_rent]>:
          - if <context.message.to_lowercase.matches[cancel]>:
            - define title:<yaml[sc_dce].read[gui.marquee.cancel_list]||<script[sc_dce_defaults].yaml_key[gui.marquee.cancel_list]>>
            - flag player sc_dce_input:!
          - else if <player.flag[sc_dce_input].size.is[==].to[1]>:
            - if <context.message.to_lowercase.matches[[0-9]*]>:
              - flag player sc_dce_input:->:<context.message>
              - define placeholder:<yaml[sc_dce].read[messages.enter_term]||<script[sc_dce_defaults].yaml_key[messages.enter_term]>>
              - define feedback:<[placeholder].replace[[price]].with[<server.economy.format[<context.message>]>]>
            - else:
              - define feedback:<yaml[sc_dce].read[messages.numbers_only]||<script[sc_dce_defaults].yaml_key[messages.numbers_only]>>
          - else if <player.flag[sc_dce_input].size.is[==].to[2]>:
            - if <context.message.to_lowercase.matches[[0-9]*]>:
              - flag player sc_dce_input:->:<context.message>
              - define placeholder:<yaml[sc_dce].read[messages.allow_renew]||<script[sc_dce_defaults].yaml_key[messages.allow_renew]>>
              - define feedback:<[placeholder].replace[[days]].with[<context.message>]>
            - else:
              - define feedback:<yaml[sc_dce].read[messages.numbers_only]||<script[sc_dce_defaults].yaml_key[messages.numbers_only]>>
          - else if <player.flag[sc_dce_input].size.is[==].to[3]>:
            - if <context.message.to_lowercase.matches[[y]]>:
              - flag player sc_dce_input:->:true
              - define placeholder:<yaml[sc_dce].read[messages.stay_rentable]||<script[sc_dce_defaults].yaml_key[messages.stay_rentable]>>
              - define feedback:<[placeholder].replace[[renewable]].with[&aAllowed]>
            - else if <context.message.to_lowercase.matches[[n]]>:
              - flag player sc_dce_input:->:false
              - define placeholder:<yaml[sc_dce].read[messages.stay_rentable]||<script[sc_dce_defaults].yaml_key[messages.stay_rentable]>>
              - define feedback:<[placeholder].replace[[renewable]].with[&cDenied]>
            - else:
              - define feedback:<yaml[sc_dce].read[messages.boolean_only]||<script[sc_dce_defaults].yaml_key[messages.boolean_only]>>
          - else if <player.flag[sc_dce_input].size.is[==].to[4]>:
            - if <context.message.to_lowercase.matches[[y]]>:
              - flag player sc_dce_input:->:true
              - define placeholder:<yaml[sc_dce].read[messages.autopay]||<script[sc_dce_defaults].yaml_key[messages.autopay]>>
              - define feedback:<[placeholder].replace[[T/F]].with[&aTrue]>
            - else if <context.message.to_lowercase.matches[[n]]>:
              - flag player sc_dce_input:->:false
              - define placeholder:<yaml[sc_dce].read[messages.autopay]||<script[sc_dce_defaults].yaml_key[messages.autopay]>>
              - define feedback:<[placeholder].replace[[T/F]].with[&cFalse]>
            - else:
              - define feedback:<yaml[sc_dce].read[messages.boolean_only]||<script[sc_dce_defaults].yaml_key[messages.boolean_only]>>
          - else if <player.flag[sc_dce_input].size.is[==].to[5]>:
            - if <context.message.to_lowercase.matches[y]>:
              - flag player sc_dce_input:->:true
            - else if <context.message.to_lowercase.matches[n]>:
              - flag player sc_dce_input:->:false
            - else:
              - define feeback:<yaml[sc_dce].read[messages.boolean_only]||<script[sc_dce_defaults].yaml_key[messages.boolean_only]>>
              - inject <script[<yaml[sc_dce].read[scripts.narrator]||<script[sc_dce_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
              - stop
            - define area:<placeholder[residence_user_current_res]>
            - define price:<player.flag[sc_dce_input].get[2]>
            - define term:<player.flag[sc_dce_input].get[3]>
            - define renew:<player.flag[sc_dce_input].get[4]>
            - define stay:<player.flag[sc_dce_input].get[5]>
            - define auto:<player.flag[sc_dce_input].get[6]>
            - execute as_player "res market rentable <[area]> <[price]> <[term]> <[renew]> <[stay]> <[auto]>"
            - flag player sc_dce_input:!
        - if <player.has_flag[sc_dce_input]>:
          - if <[feedback].exists>:
            - inject <script[<yaml[sc_dce].read[scripts.narrator]||<script[sc_dce_defaults].yaml_key[scripts.narrator]||sc_common_feedback>>]>
        - else:
          - define inv:<inventory[sc_dce_menu]>
          - inventory open d:<[inv]>
          - if <[marquee].exists>:
            - inject <script[<yaml[sc_dce].read[scripts.GUI]||<script[sc_dce_defaults].yaml_key[scripts.GUI]||sc_common_marquee>>]>
sc_dce_defaults:
  type: yaml data
  settings:
    update: true
  permissions:
    use: residence.gui
    admin: residence.admin
  scripts:
    narrator: sc_common_feedback
    GUI: sc_common_marquee
    update: sc_common_update
  messages:
    prefix: '&a&lb&2Denizence&a&rb'
    description: 'GUI for Residence Users'
    reload: '&9Plugin has been reloaded.'
    permission: '&cYou don''t have permission.'
    missing_script:
    - '&c Script [script] was not detected.'
    - '&c Installation not complete.'
    - '&c Did you install the common files?'
    enter_name: '&9Enter Residence name.&nl&7To resume chatting, type cancel, wait 60 seconds or just relog.'
    enter_subzone: '&9Enter Subzone name.&nl&7To resume chatting, type cancel, wait 60 seconds or just relog.'
    enter_player: '&9Enter Player name.&nl&7To resume chatting, type cancel, wait 60 seconds or just relog.'
    enter_message: '&9Enter your message. &aColor codes supported.&nl&7To resume chatting, type cancel, wait 60 seconds or just relog.'
    enter_price: '&9Enter the &6price &9to charge per rental term.&nl&7To resume chatting, type cancel, wait 60 seconds or just relog'
    enter_term: '&9Renewal price&co &6[price]&9. Enter lease term next.&nl&7To resume chatting, type cancel, wait 60 seconds or just relog.'
    allow_renew: '&9Lease term has been set to &a[days] &9(real) days. Allow renewing? Y/N.&nl&7To resume chatting, type cancel, wait 60 seconds or just relog.'
    stay_rentable: '&9Renew set to [renewable]&9. Stay in market? Y/N.&nl&7To resume chatting, type cancel, wait 60 seconds or just relog.'
    autopay: 'Stay in market set to [T/F]&9. Allow auto-pay? Y/N.&nl&7To resume chatting, type cancel, wait 60 seconds or just relog.'
    numbers_only: '&cPlease use numbers only.'
    boolean_only: '&cPlease use Y or N only.'
  gui:
    marquee:
      default: '   &1&lDenizence &2&oby Smellycraft'
      click_type: '     &8Left or Right click only.'
      cancel_res:
      - '&cResidence not created.'
      - '&cWere both corners unclaimed?'
      cancel_subzone:
      - '      &cSubzone not created.'
      - '   &cWere both corners inside?'
      cancel_message: '   &cNo changes to [type] message.'
      message_removed: '     &9Removed [type] message.'
      cancel_player: '     &cNo player chosen to flag.'
      cancel_list: '    &cArea was not put up for rent.'
    current:
      material:
        create: wooden_axe
        owned: oak_door
        not_owned: iron_door
      display:
        create: '&aCreate new Residence'
        owned: '&aWelcome Home'
        not_owned: '&cClaimed Land'
      lore:
        name: '&6[name]'
        owned: '&9You own this Residence.'
        not_owned: '&6&o[name]&9, Owned by &6[owner]'
        size: '&9Size: &a[size]'
        subzone: '&9Current Subzone: &6&o[subzone]'
        remove: '&fClick to remove.'
        forsale: '&9Residence is &afor sale&9.'
        saleprice: '&9Price&co &6[saleprice]'
        create: '&fClick to create a residence.'
    flags:
      material: lime_banner
      display: '&aAdjust Flags'
      lore:
        set_global: '&9Set &6global &fpermissions with &aLeft click'
        set_player: '&9Set &6player &fpermissions with &aRight click'
        editing_zone: '&9Editing Subzone&co &6&o[subzone]'
    messages:
      material: name_tag
      display: '&aChange Messages'
      lore:
        header: '&9Change the Enter or Leave messages.'
        buttons_1: '&aLeft-click &ffor Enter, &aRight-click &ffor Leave.'
        buttons_2: '&aShift-click &f to remove a message.'
        editing_zone: '&9Editing Subzone&co &6&o[subzone]'
    size:
      material: stick
      display: '&aExpand or Contract'
      lore:
        header: '&9Look up, down, or in any direction.'
        buttons: '&aLeft-click &fexpands, &aRight-click &fcontracts.'
        limits_1: '&cYour size limits are&co'
        limits_2: '&7X&co &a[maxew]&7, Y&co &a[maxud]&7, Z&co &a[maxns]'
        editing_zone: '&9Editing Subzone&co &6&o[subzone]'
    zones:
      material: oak_fence
      display: '&aManage Subzones'
      lore:
        header: '&9Select two points within a Residence.'
        buttons: '&aLeft-click &fcreates, &aRight-click &fremoves.'
        editing_zone: '&9Editing Subzone&co &6&o[subzone]'
    market:
      material:
        list: tripwire_hook
        unlist: tripwire_hook
        rented: tripwire_hook
        forrent: tripwire_hook
        sell: oak_sign
        unsell: oak_sign
        forsale: oak_sign
      display:
        list: '&aMake Rentable'
        unlist: '&aRemove from Market'
        rented: '&aCurrently Renting'
        forrent: '&aSpace for Rent'
        sell: '&aSell this Residence'
        unsell: '&aRemove from Market'
        forsale: '&aFor Sale'
      lore:
        tenant: '&9Currently rented by &6[renter]'
        due: '&9Renewal date&co &a[renewdate]'
        cost: '&9You will be debited &6[rentprice]'
        vacant: '&9Rentable for &6[rentprice]'
        unrent: '&fClick to unrent.'
        list: '&fClick to put this area up for rent.'
        unlist: '&fClick to remove from the market.'
        period: '&9Renews every &a[rentperiod] day(s).'
        newrent: '&fClick to rent this property.'
        evict: '&fClick to evict this tenant.'
        editing_zone: '&9Editing Subzone&co &6&o[subzone]'
