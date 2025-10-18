// Arquivo: functions/index.js (VERSÃO FINAL COM REGIÃO ESPECÍFICA)

const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

// Define a região para todas as funções neste arquivo
setGlobalOptions({ region: "southamerica-east1" });

admin.initializeApp();
const db = admin.firestore();

// --- Cloud Function para LOGGING AUTOMÁTICO ---
exports.logQuestionnaireSubmission = onDocumentCreated("users/{userId}/questionnaireSubmissions/{submissionId}", (event) => {
  const snap = event.data;
  if (!snap) {
    logger.log("No data associated with the event");
    return;
  }
  const submissionData = snap.data();
  const userId = event.params.userId;
  const submissionId = event.params.submissionId;

  const logMessage = `Usuário ${userId} enviou o questionário ${submissionId} em ${submissionData.date.toDate().toISOString()}`;
  
  logger.log(logMessage);

  return db.collection("logs").add({
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    event: "QUESTIONNAIRE_SUBMITTED",
    message: logMessage,
    details: {
      userId: userId,
      submissionId: submissionId,
    },
  });
});

// --- Cloud Function para API REST ---
exports.getDailyCheckinCount = onRequest({ cors: true }, async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const snapshot = await db.collectionGroup("moodEntries")
      .where("date", ">=", today)
      .where("date", "<", tomorrow)
      .get();
    
    const count = snapshot.size;
    logger.info(`Contagem de check-ins para ${today.toISOString()}: ${count}`);

    res.status(200).json({
      date: today.toISOString().split("T")[0],
      dailyCheckinCount: count,
    });
  } catch (error) {
    const errorMessage = error.details || error.message;
    logger.error("ERRO FOCADO NA CRIAÇÃO DO ÍNDICE:", errorMessage);
    res.status(500).send(`Ocorreu um erro. O Firestore precisa de um índice. Verifique os logs da função para o link de criação. Detalhe do erro: ${errorMessage}`);
  }
});