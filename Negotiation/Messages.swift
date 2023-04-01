//
//  Messages.swift
//  Negotiation
//
//  Created by CogModel on 18/03/2023.
//

import Foundation



// SENTENCES the messages between players


let openingMSGs = [
    "Hello there,  %@.", 
    "Hi %@, nice to meet you.",
    "Greetings, %@.",
    "Hello %@, I hope you're doing well today.",
    "Hi there, %@. Shall we get started?",
    "Good day, %@. Let's begin our negotiation.",
    "Hello %@, I'm looking forward to working with you.",
    "Hi %@, it's great to connect with you. How can we proceed?",
    "Greetings, %@. I'm excited to negotiate with you.",
    "Hello %@, I appreciate the opportunity to negotiate with you."
]


let mnsDeclarationMSGs = [
    "Just to be transparent, my MNS for this negotiation is %d.", 
    "I wanted to let you know that %d is my MNS for this negotiation.", 
    "Before we begin, I should mention that my MNS is %d.", 
    "To be upfront, I won't be able to accept anything less than %d, which is my MNS.", 
    "I'd like to establish from the outset that my MNS is %d.", 
    "Let's be clear: my MNS for this negotiation is %d.", 
    "Before we proceed, I need to make it clear that my MNS is %d.", 
    "I think it's important to share that my MNS for this negotiation is %d.", 
    "Before we delve deeper, I want to state that my MNS is %d.", 
    "Just so we're on the same page, %d is my MNS for this negotiation.", 
    "Before we begin, I should let you know that my MNS for this negotiation is %d.",
    "Just to clarify, %d is my MNS for this negotiation.",
    "Before we dive in, I want to state that my MNS is %d.",
    "I think it's important to mention that my MNS is %d for this negotiation.",
    "Let's set some expectations. My MNS for this negotiation is %d.",
    "Thanks for joining me. Before we get started, I want to establish that my MNS is %d."
]

// could be separated in different tones
let mnsResponseMSGsCoopNeutral = [
    "Thank you for letting me know. My MNS is %d, so I believe we can find a mutually beneficial solution.",
    "I appreciate the transparency. My MNS is %d.",
    "Thanks for sharing. My MNS is %d, but I'm sure we can reach an agreement that meets both our needs.",
    "Okay. My MNS is %d, but I'm open to exploring different options with you.",
    "Got it. My MNS is %d, but I'm willing to see if we can come up with a solution that works for both of us.",
    "Thank you for being upfront. My MNS is actually %d, but I'm open to discussing different scenarios with you.",
    "I see. My MNS is %d, so I think we can find a compromise that satisfies us both.",
    "Thanks for sharing your MNS. Mine is %d.",
    "I appreciate your honesty. My MNS is %d, but I'm open to exploring different ways we can reach a mutually beneficial agreement.",
    "Understood. My MNS is %d, but I'm willing to negotiate and see if we can find common ground."
]


let mnsResponseMSGsAggressive = [
    "That's higher than I was expecting. My MNS is actually %d, so I'm not sure we're going to find common ground.",
    "I appreciate your honesty, but my MNS is %d, and I won't accept anything less.",
    "I understand where you're coming from, but my MNS is non-negotiable at %d.",
    "Thanks for sharing, but my MNS is %d, and I won't consider anything below that.",
    "I appreciate your transparency, my MNS is firm at %d.",
    "My MNS is %d, and I won't budge on that.",
    "I appreciate your willingness to negotiate, my MNS is set at %d, and I won't consider anything less"
]



let bidMSGs = [
    "I'll bid %d points, you'd get %d.",
    "I want %d points, which leaves %d for you.",
    "I want %d points, which would leave %d points for you.",
    "What about %d points for me, and %d points for you?",
    "I'd like to do this; %d points for me, %d for you. How does that sound?",
    "We can split the 9 points like this; %d to me, %d for you.", 
    "I'm willing to bid %d points, and that would leave %d for you.",
    "Let's split the points %d for me and %d for you, does that work?", 
    "How about I bid %d points, and you get %d points in return?", 
    "I propose %d points for me, %d points for you. What do you think?", 
    "If I bid %d points, would you be willing to accept %d points?", 
    "I suggest we split the points %d for me and %d for you. Agreed?", 
    "I'll bid %d points, and you'll receive %d points. Does that seem fair?", 
    "What if I bid %d points, and you get %d points out of the total?", 
    "I'm thinking %d points for me and %d points for you. How does that sound?", 
    "Let's agree on %d points for me and %d points for you. Deal?"
]

let insistMSGs = [
    "I insist, I want %d points, which leaves %d for you.",
    "No, thank you. My offer still stands: %d points for me and %d for you.",
    "I understand your position, but I really insist on getting %d points, which still leaves %d for you.",
    "I appreciate your offer, but I'm still insistent on %d points for me and %d points for you.",
    "I really think %d points for me and %d points for you is the best deal. I insist we go with that.",
    "I'm sorry, but I must insist on %d points for myself, and %d points for you.",
    "I respect your opinion, but I insist that %d points for me and %d points for you is the fairest split.",
    "I hear what you're saying, but I still want %d points for me and %d points for you. Can we please agree on that?",
    "I insist that %d points for me and %d points for you is the best option.",
    "I appreciate your efforts to find a compromise, but I must insist on %d points for me and %d points for you."
]

let acceptingSentencesNeutral = [
    "I accept your offer.",
    "That's acceptable, I'm in.",
    "Sounds good, I accept.",
    "Count me in, I accept.",
    "I'm happy to accept.",
    "I agree, I accept.",
    "I'm ready to proceed, I accept.",
    "Yes, let's do it, I accept.",
    "I'm fine with that, I accept.",
    "Alright, I accept."
]

let decliningSentencesNeutral = [
    "I must decline, thank you.",
    "I'm unable to accept, thanks.",
    "I appreciate the offer, but I must decline.",
    "That won't be possible, thanks.",
    "Thanks for the offer, but I can't accept.",
    "Unfortunately, I have to decline.",
    "Thank you, but I can't accept.",
    "I'm honored, but I have to decline.",
    "I'm sorry, but I have to decline.",
    "I'm unable to accept at this time."
]

let acceptingSentencesHappy = [
    "Yes! Thank you so much!",
    "Awesome, I'm in!",
    "Absolutely, I accept!",
    "Yay! Let's do it!",
    "I'm thrilled, I accept!",
    "Fantastic, count me in!",
    "Yes, this is perfect!",
    "I'm excited, I accept!",
    "This is great news, I accept!",
    "Thank you, I'm so happy to accept!"
]

let acceptingSentencesAngry = [
    "Fine, I'll accept.",
    "Whatever, I accept.",
    "Okay, I guess I'll accept.",
    "Sure, I accept.",
    "If I have to, I'll accept.",
    "Ugh, fine, I accept.",
    "I suppose I'll accept.",
    "Joy of joys, I accept.",
    "Alright, I'll accept.",
    "Don't get too excited, but I accept."
]

let decliningSentencesHappy = [
    "Thanks, but I'm going to decline.",
    "I appreciate the offer, but I'll pass.",
    "Thank you, but I have to say no.",
    "That's very kind, but I can't accept.",
    "I'm grateful, but I have to decline.",
    "I'm honored, but I'll have to say no.",
    "Thanks for considering me, but I'll decline.",
    "I appreciate it, but I can't accept.",
    "I'm flattered, but I'll have to decline.",
    "Thanks, but I'll have to pass."
]

let decliningSentencesAngry = [
    "No way, not interested.",
    "Absolutely not, don't waste my time.",
    "You must be joking, no thanks.",
    "Not a chance, no thanks.",
    "You've got to be kidding me, no way.",
    "Nope, not interested.",
    "I don't think so, no thanks.",
    "Save your breath, no thanks.",
    "I'm not even going to dignify that with a response.",
    "Don't even bother asking."
]
