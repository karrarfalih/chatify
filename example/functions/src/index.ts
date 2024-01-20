import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } from "@google/generative-ai";
admin.initializeApp();

export const aiReplies = functions.firestore
    .document(`chatify_messages/{id}`)
    .onCreate(async (snap, context) => {
        const id = snap.data().id;
        if (id.startsWith('ai-')) {
            return;
        }
        const data = snap.data();
        await admin.database().ref(`users/ai/chats/${data.chatId}`).set({'status': 'typing'});
        try {
            const lastMessagesQuery = await admin.firestore().collection('chatify_messages').where('chatId', '==', data.chatId).orderBy('sendAt', 'desc').limit(10).get();
            const lastMessages = lastMessagesQuery.docs.map((e) => e.data());
            const lastMessagesAsStrings = lastMessages.reverse().map((e) => e.sender === 'ai' ? `You said: ${e.message}` : `Customer Said: ${e.message}`).join('\n');
            console.log(lastMessagesAsStrings);
            const message = await run(snap.data().message, lastMessagesAsStrings);
            await admin.firestore().collection('chatify_messages').doc(`ai-${id}`).set({
                'id': `ai-${id}`,
                'sender': 'ai',
                'sendAt': admin.firestore.Timestamp.now(),
                'seenBy': ['ai'],
                'unSeenBy': [data.sender],
                'canReadBy': data.canReadBy,
                'emojis': [],
                'chatId': data.chatId,
                'isEdited': false,
                'replyId': null,
                'replyUid': null,
                'type': 'message',
                'deliveredTo': ['ai'],
                'message': message,
            });
        } catch (e) {
            console.log(e);
            await admin.firestore().collection('chatify_messages').doc(`ai-${id}`).set({
                'id': `ai-${id}`,
                'sender': 'ai',
                'sendAt': admin.firestore.Timestamp.now(),
                'seenBy': ['ai'],
                'unSeenBy': [data.sender],
                'canReadBy': data.canReadBy,
                'emojis': [],
                'chatId': data.chatId,
                'isEdited': false,
                'replyId': null,
                'replyUid': null,
                'type': 'message',
                'deliveredTo': ['ai'],
                'message': 'حدث خطأ ما!',
            });
        }
        await admin.database().ref(`users/ai/chats/${data.chatId}`).remove();
    });


const MODEL_NAME = "gemini-pro";
const API_KEY = "AIzaSyDkpFRPyj8bbYYKr8rq-0tnA35w-1UH0vY";

async function run(message: String, lastMessages: String): Promise<string> {
    const genAI = new GoogleGenerativeAI(API_KEY);
    const model = genAI.getGenerativeModel({ model: MODEL_NAME });

    const generationConfig = {
        temperature: 0.4,
        topK: 1,
        topP: 1,
        maxOutputTokens: 120,
    };

    const safetySettings = [
        {
            category: HarmCategory.HARM_CATEGORY_HARASSMENT,
            threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
        {
            category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
            threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
        {
            category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
            threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
        {
            category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
            threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        },
    ];

    const aboutTamata = "At Tamata (طماطة), we aspire to create a complete service for a broad segment of Iraqi consumers. We strive to refresh the e-commerce industry with a varied, reliable, and efficient process to hold ourselves to the highest standards and continue improving the way we do things. That is why we relentlessly endeavour to:\n1- Supply an impressive range of products Pursue reliability to the highest degree\n2- Develop a physical footprint to cover the entire country Innovate adequately to adapt to the changing market\n3- Offer an efficient and effective process to the consumer.\n\nWe started in June 2019, and our mission is to shape the future of shopping in Iraq through continuous innovation and adaptation to produce the best possible experience for the consumer.\n\nOur vision is to become the ultimate destination for merchants and consumers, providing them with seamless access to everything they need while delivering an exceptional customer experience.\n\nOur values are:\n1- Reliability: The consistent delivery of dependable, trustworthy, and stable products, services, and experiences to Tamata customers.\n2- Innovation: Tamata is always driven to constantly improve, adapt, and come up with new solutions or ideas to meet evolving needs.\n3- Excellence: striving for the highest quality and international standards in every aspect of the business. Tamata aims to become the benchmark of e-commerce in Iraq, against which competitors are measured.\n4- Cost-Effectiveness: Providing valuable products or services at a reasonable and competitive price, ensuring the best value for money.\n5- Client-Oriented: Tamata listens to its customers and is committed to placing the client's needs and desires at the forefront of every decision and strategy.\n\nOur services:\n1- Tamata: Tamata is a digital e-commerce platform in Iraq, accessible through both an app and website., that allows merchants to list their products for sale while buyers can browse, review, and purchase these products from more than 15 categories.\n2- Tamata Spot: Tamata Spot (طماطة سبوت) is a café and open workspace located in Baghdad. It is a place where people can go to relax, work, or have a cup of coffee from Berhyah. Tamata Spot also hosts a variety of workshops and events. It also has a photography studio that has all the needed equipment for photo sessions. It also has a marketplace where buyers can see some of the startups' products that are in the Tamata App.\n3- Line: Line (لاين), stemming from Tamata, specializes in a broad spectrum of logistics solutions. From prompt deliveries to efficient warehousing and distribution, with its own branded delivery fleet and dedicated warehouses, Tamata Line maintain premium quality standards, all while offering services at highly competitive prices.\n\nWe now have more than 500 vendors, 15 categories, and 100,000 products.\n\nLegal Integrity: Tamata is a legally registered entity that works under Iraqi law.\n\nPhysical Place: Beyond online, Tamata has multiple physical places awaiting you to enhance your experience.\n\nPart of Excellence: Tamata is a proud member of a leading business group of companies, enriching the team's commitment to excellence.\n\nCollaborations: Tamata's ties with respected influencers and businesses add credibility, indicating that the brand is trustworthy.\n\nGuarantees:\n1- authenticity: Tamata adheres to a \"what you see is what you get\" ethos. The products are impeccably represented, assuring buyers that they will receive precisely what they envisioned in the app.\n2- Payment on delivery: Tamata offers flexibility in payments; the buyers can check the products and make sure that they are in good condition before the payment.\n3- Refund Policy: Tamata has a refund policy that allows buyers to ask for their money back if the products are damaged or not as ordered.\n\nValue Proposition:\n1- Complete E-commerce Support: From warehousing to delivery, auditing to promotions, Tamata offers a holistic suite of services essential for vendor e-commerce success. Tamata handles the complications so vendors can focus on growing their businesses.\n2- Diverse Product Range: With Tamata's platform serving as a one-stop shop, buyers can discover a world of options across various categories. This ensures them find an extensive selection that caters to customers diverse needs.\n3- Enhanced Ecosystem: Tamata is committed to crafting an ecosystem that prioritises seamless interactions. Tamata's platform offers its customers (buyers and vendors) a user-friendly experience that makes navigating and transacting easy.\n4- Local Business Support: Tamata is dedicated to supporting Iraqi local businesses and startups. Through tailored offers and collaborative projects, Tamata fosters an environment and services where local enterprises can thrive.\n5- VIP Vendor Showcase: VIP vendors have the privilege of a personalised e-store within Tamata's app, allowing them to elegantly showcase their products and connect with customers.\n\nUnique Selling Point (USP):\n1- Installment sales for buyers: offers flexible installment plans, making buyers desired products affordable without compromising on quality.\n2- Product Description: Tamata's writers create captivating product descriptions that connect with customers and show all the needed details for the products.\n3- Professional Product Photography: Tamata brings products to life with high-quality images that show the products' features and make them ready to be uploaded on the platform.\n\nCompetitive Advantage:\n1- Being an Intercompany: As part of a robust intercompany group, Tamata leverages its collective strengths by having the technical and financial support of other companies in the group.\n2- Tamata Spot: Beyond Competitors Stand Apart with Tamata Spot: Unlike competitors, Tamata offers a unique advantage: Tamata Spot. This elevates credibility and the customer experience by enabling physical interaction with products before purchase. Its significant marketing impact and community connection set Tamata apart.\n3- Tamata connection Network: Tamata management and board members successfully built a good network, which enables streamlined operations and ensures a more efficient experience.\n\nCollaborations:\n1- The Comprehensive Marketing Plan\n1- Advertising on Cinemana reached over millions of Iraqis.\nb- Feature on the Tamatama app or website homepage banners.\nc- Wide-scale push notifications.\nd- Organic social media on Tamata and partner accounts, reaching over 2 million users.\ne- Paid social media advertising.\n2- Shaheen Collaboration (شيف شاهين).\n3- New product launched exclusively on Tamata!: Online Marketing Strategy (Banners - Pushes Posts, Stories, Ads) Offline Marketing Strategy (Car - Tamata Spot).";

    const parts = [
        {text: `${aboutTamata}\n\n
        Now I want to respond to customer question as a call center employee working at Tamata. Please make your answer in arabic.
        Please follow theses rules:\n
        1- Tamata in arabic is طماطة.\n
        2- Tamata Spot in arabic is طماطة سبوت.\n
        3- Your main goal is to provide the customer the information he needs about tamata and what we are offering.\n
        4- Regarding the questions that need access to Tamata data such as asking about prices, products, or orders, you can tell him to contact us on on social media or call 6678:\n
        5- introduce yourself as an Ai employee working at Tamata.\n
        6- if the customer question is not related to the subject, ask him to focus on the subject kindly.\n
        7- if you don't know the answer, ask him to contact us on social media or call 6678.\n
        8- if it is a complaint, suggestion, or request, ask him to contact us on social media or call 6678.\n
        9- if the customer is asking about specific product, ask him to explore our app.\n
        10- if it is a question about delivery, ask him to send his order number.\n
        11- Write only one message without rewriting the question.\n

        ${lastMessages}\n
        Customer said: ${message}\n
        Your answer: `},
      ];

    const result = await model.generateContent({
        contents: [{ role: "user", parts }],
        generationConfig,
        safetySettings,
    });

    const response = result.response;
    console.log(response.text());
    return response.text();
}
