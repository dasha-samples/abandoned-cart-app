// Import the commonReactions library so that you don't have to worry about coding the pre-programmed replies
import "commonReactions/all.dsl";

context
{
// Declare the input variable - phone. It's your hotel room phone number and it will be used at the start of the conversation.  
    input phone: string;
// Storage variables. You'll be referring to them across the code. 
    new_model: string="";
}

// A start node that always has to be written out. Here we declare actions to be performed in the node. 
start node root
{
    do
    {
        #connectSafe($phone); // Establishing a safe connection to the user's phone.
        #waitForSpeech(1000); // Waiting for 1 second to say the welcome message or to let the user say something
        #sayText("Hi, this is Dasha with JJC Group. I see you have the latest model of the Pear laptop in your cart and haven't completed the order on our website. Is it a good time to talk?"); // Welcome message
        wait *; // Wating for the user to reply
    }
    transitions // Giving directions to which nodes the conversation will go to
    {
        how_can_i_assist: goto how_can_i_assist on #messageHasIntent("yes");
        bye: goto bye on #messageHasIntent("no");
    }
}

node how_can_i_assist
{
    do
    {
        #sayText("Wonderful! This won't take too long. I was just wondering if you have any concerns regarding the purchase of the laptop that's in your cart?");
        wait*;
    }
    transitions
    {

    }
}

digression offer_discount
{
    conditions {on #messageHasIntent("price_too_high");}
    do 
    {     
        #sayText("I totally understand your concern and I have a sweet offer for you to consider! How would you feel about a 3 percent discount on this purchase?"); 
        wait*;
    }
    transitions
    {
        any_other_concern: goto any_other_concern on #messageHasIntent("no");
        complete_purchase: goto complete_purchase on #messageHasIntent("yes");
    }
}

node offer_discount
{
    do 
    {     
        #sayText("I totally understand your concern and I have a sweet offer for you to consider! How would you feel about a 3 percent discount on this purchase?"); 
        wait*;
    }
    transitions
    {
        any_other_concern: goto any_other_concern on #messageHasIntent("no");
        complete_purchase: goto complete_purchase on #messageHasIntent("yes");
    }
}

digression found_it_elsewhere
{
    conditions {on #messageHasIntent("found_it_elsewhere");}
    do 
    {     
        #sayText("Well, that happens! I'm glad you were able to find what you were looking for, even if it wasn't with us. But could I ask you what made you decide to look at another place?"); 
        wait*;
    }
    transitions
    {
        ask_if_purchased: goto ask_if_purchased on #messageHasIntent("cheaper_elsewhere");
        free_delivery_elsewhere: goto free_delivery_elsewhere on #messageHasIntent("free_delivery_elsewhere")  or #messageHasIntent("delivery_price_too_high");
        more_options_elsewhere: goto more_options_elsewhere on #messageHasIntent("more_options_elsewhere") or #messageHasIntent("another_option_elsewhere");
        future_discount: goto future_discount on #messageHasIntent("price_too_high");
    }
}

node ask_if_purchased
{
    do 
    {     
        #sayText("Uh-huh, understood. May I ask if you've bought it at that other place?"); 
        wait*;
    }
    transitions
    {
        offer_new_item_discount: goto offer_new_item_discount on #messageHasIntent("yes") or #messageHasIntent("purchased_elsewhere");
        offer_discount: goto offer_discount on #messageHasIntent("no")  or #messageHasIntent("didn't_purchase_elsewhere");
    }
}

digression need_another_thing
{
    conditions {on #messageHasIntent("need_another_thing");}
    do 
    {     
        #sayText("That's fine too, what is it what you're looking for?"); 
        wait*;
    }
}

digression ask_another_model
{
    conditions {on #messageHasIntent("another_model");}
    do 
    {     
        #sayText("Do you have a specific model in mind?"); 
        wait*;
    }
    transitions
    {
        other_models: goto other_models on #messageHasIntent("no") or #messageHasIntent("unsure");
        another_model: goto another_model on #messageHasData("laptop_model");
    }
}

digression other_models
{
    conditions {on #messageHasIntent("unsure") or #messageHasIntent("models_available");}
    do 
    {     
        #sayText("I just sent a link to all the similar models we have to your email. You'll find all the features, price, and all the other info you need right there. It's gonna be a pretty useful link for you! Now, do you have any other concerns regarding your purchase?"); 
        wait*;
    }
    transitions
    {
        how_may_i_help: goto how_may_i_help on #messageHasIntent("yes");
        email_sent_bye: goto email_sent_bye on #messageHasIntent("no");
    }
}

node other_models
{
    do 
    {     
        #sayText("I just sent a link to all the similar models we have to your email. You'll find all the features, price, and all the other info you need right there. It's gonna be a pretty useful link for you! Now, do you have any other concerns regarding your purchase?"); 
        wait*;
    }
    transitions
    {
        how_may_i_help: goto how_may_i_help on #messageHasIntent("yes");
        email_sent_bye: goto email_sent_bye on #messageHasIntent("no");
    }
}

node how_may_i_help
{
    do 
    {     
        #sayText("What may I help you with?"); 
        wait*;
    }
    transitions
    {

    }
}

digression how_may_i_help
{
    conditions {on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure");}
        do 
    {     
        #sayText("Is there anything I can do to improve your shopping experience with us or help you in any kind of way?"); 
        wait*;
    }
}


digression another_model
{
    conditions {on #messageHasData("laptop_model");}
    do 
    {   
        set $new_model =  #messageGetData("laptop_model")[0]?.value??"";
        #sayText("We have  " + $new_model + " available! I've just added to your cart. And as a small gift I'll added a 3 percent discount coupon to your next purchase. Does this offer sound good to you?");
        wait *;
    }
    transitions
    {
        send_link_to_purchase: goto send_link_to_purchase on #messageHasIntent("yes") or #messageHasIntent("sounds_good");
        final_offer_bye: goto final_offer_bye on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure");
    }
}

node another_model
{
    do 
    {   
        set $new_model =  #messageGetData("laptop_model")[0]?.value??"";
        #sayText("We have  " + $new_model + " available! I've just added to your cart. And as a small gift I'll added a 3 percent discount coupon to your next purchase. Does this offer sound good to you?");
        wait *;
    }
    transitions
    {
        send_link_to_purchase: goto send_link_to_purchase on #messageHasIntent("yes") or #messageHasIntent("sounds_good");
        final_offer_bye: goto final_offer_bye on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure");
    }
}

digression payment_options
{
    conditions {on #messageHasIntent("waiting_for_salary") or #messageHasIntent("not_enough_money");}
    do 
    {     
        #sayText("Gotcha. I wanted to let you know that we have an installment plan you can take advantage of. Is it something you feel like considering?"); 
        wait*;
    }
    transitions
    {
        confirm_installment: goto confirm_installment on #messageHasIntent("yes") or #messageHasIntent("agreed_installment");
        trade_in: goto trade_in on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure");
    }
}

digression installment_plan
{
    conditions {on #messageHasIntent("installment_plan");}
    do 
    {     
        #sayText("That's right, we have an installment plan you can take advantage of. Is it something you feel like considering?"); 
        wait*;
    }
    transitions
    {
        confirm_installment: goto confirm_installment on #messageHasIntent("yes") or #messageHasIntent("agreed_installment");
        trade_in: goto trade_in on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure");
    }
}

digression delivery_price_too_high
{
    conditions {on #messageHasIntent("delivery_price_too_high");}
    do 
    {     
        #sayText("I'm sorry you feel that way! What I can do you you this time is offer you a one-time free delivery. How does that sound?"); 
        wait*;
    }
    transitions
    {
        offer_expires_soon_bye: goto offer_expires_soon_bye on #messageHasIntent("yes") or #messageHasIntent("sounds_good");
        final_offer_bye: goto final_offer_bye on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure");
    }
}

digression country_delivery
{
    conditions {on #messageHasIntent("my_country_delivery");}
    do 
    {     
        #sayText("I apologize for the inconvenience! We can think of a way to send you your purchase. We have a USPS delivery option and it does deliver to your country. The delivery costs 57 dollars. How does this sound to you?"); 
        wait*;
    }
    transitions
    {
        send_with_usps: goto send_with_usps on #messageHasIntent("yes") or #messageHasIntent("sounds_good");
        no_dice_bye: goto no_dice_bye on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("sounds_bad") or #messageHasIntent("unsure");
    }
}

node trade_in
{
    do 
    {     
        #sayText("Oh, by the way, there's also a trade in option. You can bring your old laptop to us and have a heavy discount for a new one. Does this sound like a plan?"); 
        wait*;
    }
    transitions
    {
        confirm_trade_in: goto confirm_trade_in on #messageHasIntent("yes") or #messageHasIntent("agreed_trade_in") or #messageHasIntent("sounds_good");
        final_offer_bye: goto final_offer_bye on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure") or #messageHasIntent("sounds_bad");
    }
}

digression trade_in
{
    conditions {on #messageHasIntent("trade_in");}
    do 
    {     
        #sayText("Absolutely! We do have a trade in option. You can bring your old laptop to us and have a heavy discount for a new one. Does this sound like a plan?"); 
        wait*;
    }
    transitions
    {
        confirm_trade_in: goto confirm_trade_in on #messageHasIntent("yes") or #messageHasIntent("agreed_trade_in") or #messageHasIntent("sounds_good");
        final_offer_bye: goto final_offer_bye on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure") or #messageHasIntent("sounds_bad");
    }
}

digression not_sure
{
    conditions {on #messageHasIntent("unsure");}
    do 
    {     
        #sayText("In this case, may I ask what are you concerned about?"); 
        wait*;
    }
}

digression was_just_browsing
{
    conditions {on #messageHasIntent("was_just_browsing");}
    do 
    {     
        #sayText("Haha okay, that's fine too! Just so you know, we have a big sale coming up, so watch out for an email announcement! Thank you for taking the time to talk, have an awesome day! Bye!"); 
        exit;
    }
}

node any_other_concern
{
    do 
    {     
        #sayText("Do you have any other concerns regarding completing the purchase?"); 
        wait*;
    }
    transitions
    {

    }
}

node complete_purchase
{
    do 
    {     
        #sayText("Fantastic, glad you liked it! I've added the discount for the purchase to your account, hope you enjoy your shopping experience with us! Bye bye!"); 
        exit;
    }
}

node free_delivery_elsewhere
{
    do 
    {     
        #sayText("Got that. I understand what you mean. We care about our customers having the best experience possible, so I would like to offer you free delivery for your next purchase. How does that sound to you?"); 
        wait*;
    }
    transitions
    {
        bye: goto bye on #messageHasIntent("sounds_good") or #messageHasIntent("free_delivery_sounds_good");
        final_offer_bye: goto final_offer_bye on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure") or #messageHasIntent("sounds_bad");
    }
}

node more_options_elsewhere
{
    do 
    {     
        #sayText("Ah, I understand. JJC group has lots of different options of various laptops you can choose from. I just sent a selection of different laptop models you might like. It's now available on your web account. I hope you like the seleciton and find some options you like most. Does this sound good?"); 
        wait*;
    }
    transitions
    {
        bye: goto bye on #messageHasIntent("sounds_good") or #messageHasIntent("free_delivery_sounds_good");
        final_offer_bye: goto final_offer_bye on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure") or #messageHasIntent("sounds_bad");
    }
}


node future_discount
{
    do 
    {     
        #sayText("I totally understand your concern. What I can do for you is offer a 5 percent discount on your next purchase. I hope this improves your shopping experience with us! Would you be okay with this future discount?"); 
        wait*;
    }
    transitions
    {
        bye: goto bye on #messageHasIntent("sounds_good") or #messageHasIntent("yes");
        final_offer_bye: goto final_offer_bye on #messageHasIntent("no") or #messageHasIntent("need_to_consider") or #messageHasIntent("unsure") or #messageHasIntent("sounds_bad");
    }
}


node offer_new_item_discount
{
    do 
    {     
        #sayText("Gotcha. I hope you enjoy your new purchase! And just as a small gift from us I'd like to offer you a 5 percent discount on all the laptop accessories we have."); 
        wait*;
    }
    transitions
    {
        bye: goto bye on #messageHasIntent("no") or #messageHasIntent("sounds_bad");
        offer_expires_soon_bye: goto offer_expires_soon_bye on #messageHasIntent("yes") or #messageHasIntent("sounds_good");
    }
}

node email_sent_bye
{
    do 
    {     
        #sayText("Awesome. The email must have reached you by now, so check it out! Thank you for taking the time to talk, have an awesome day! Bye!"); 
        exit;
    }
}


node send_link_to_purchase
{
    do 
    {     
        #sayText("Perfect, I'm glad to hear that! You'll see the laptop added to your cart and also I'm about to send a link to your email which will let you complete the purchase in one click. Thank you for taking the time to talk, have an awesome day! Bye!"); 
        exit;
    }
}

node final_offer_bye
{
    do 
    {     
        #sayText("As a final offer I would like to give you a 5 percent discount coupon, I just added it to your account. It expires in two weeks so make sure you don't lose the opportunity to use the discount! Thank you for taking the time to chat, bye bye!"); 
        exit;
    }
}

node confirm_installment
{
    do 
    {     
        #sayText("Alright, you can now use the installment plan option for your purchase! Is there anything else I can help you with?"); 
        wait*;
    }
    transitions
    {
        bye: goto bye on #messageHasIntent("no");
        how_may_i_help: goto how_may_i_help on #messageHasIntent("yes") or #messageHasIntent("something_else_to_ask");
    }
}

node confirm_trade_in
{
    do 
    {     
        #sayText("Alright, I've made a note of this. You can come to any convenient location for the trade-in, or send your laptop to us via mail and do the rest online. Is there anything else I can help you with?"); 
        wait*;
    }
    transitions
    {
        bye: goto bye on #messageHasIntent("no");
        how_may_i_help: goto how_may_i_help on #messageHasIntent("yes") or #messageHasIntent("something_else_to_ask");
    }
}

node offer_expires_soon_bye
{
    do 
    {     
        #sayText("Okay! Just to let you know this offer expires in 2 weeks, so make sure you use it before it expires. Is there anything else I could help you with?"); 
        wait*;
    }
    transitions
    {
        bye: goto bye on #messageHasIntent("no");
        how_may_i_help: goto how_may_i_help on #messageHasIntent("yes") or #messageHasIntent("something_else_to_ask");
    }
}

node send_with_usps
{
    do 
    {     
        #sayText("Perfect, you'll have an option in your account to check out and get your laptop delivered by USPS. Do you have any questions?"); 
        wait*;
    }
    transitions
    {
        bye: goto bye on #messageHasIntent("no");
        how_may_i_help: goto how_may_i_help on #messageHasIntent("yes") or #messageHasIntent("something_else_to_ask");
    }
}

node no_dice_bye
{
    do 
    {     
        #sayText("I'm sorry I couldn't be of help to you today. Thank you for taking the time to talk, have an awesome day! Bye!"); 
        exit;
    }
}

digression bye 
{
    conditions { on #messageHasIntent("bye") or #messageHasIntent("no") or #messageHasIntent("thank_you");}
    do 
    {
        #sayText("Thanks for your time. We're looking forward to you shopping with us! Have a great day. Bye!");
        exit;
    }
}

node bye 
{
    do 
    {
        #sayText("Thanks for your time. We're looking forward to you shopping with us! Have a great day. Bye!");
        exit;
    }
}
