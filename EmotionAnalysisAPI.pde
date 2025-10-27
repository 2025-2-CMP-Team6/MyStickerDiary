// EmotionAnalysisAPI.pde

import java.net.*;
import java.io.*;
import java.util.HashMap;

// API Setting
String EA_HF_TOKEN = "";  // When Blank, Get It from HF_TOKEN
String EA_MODEL    = "clapAI/modernBERT-base-multilingual-sentiment";

// Hash Map
HashMap<String, Float> diarySentiments = new HashMap<String, Float>();

// Result Clss
class SentimentResult {
  float score01;     // 0.0 ~ 1.0
  String label;      // "Very Negative" ~ "Very Positive"
  String distText;   
}

String makeDateKey(int y, int m, int d) {
  return y + "-" + m + "-" + d;
}

String labelFromScore(float s) {
  if (s < 0.2f) return "Very Negative";
  if (s < 0.4f) return "Negative";
  if (s < 0.6f) return "Neutral";
  if (s < 0.8f) return "Positive";
  return "Very Positive";
}

// Analyze Text
SentimentResult EA_analyzeText(String text) {
  SentimentResult out = new SentimentResult();
  out.score01 = 0.5f;  // Default Value
  out.label = "Neutral";
  out.distText = "";

  try {
    String token = EA_HF_TOKEN;
    if (token == null || token.trim().isEmpty()) token = System.getenv("HF_TOKEN");
    if (token == null || token.trim().isEmpty()) {
      println("[EmotionAPI] Missing token (EA_HF_TOKEN / env HF_TOKEN)");
      return out;
    }
    token = token.trim();

    String api = "https://api-inference.huggingface.co/models/" + URLEncoder.encode(EA_MODEL, "UTF-8");
    HttpURLConnection conn = (HttpURLConnection) new URL(api).openConnection();
    conn.setRequestMethod("POST");
    conn.setRequestProperty("Authorization", "Bearer " + token);
    conn.setRequestProperty("Content-Type", "application/json");
    conn.setRequestProperty("Accept", "application/json");
    conn.setDoOutput(true);

    String body = "{\"inputs\": " + JSONObject.quote(text == null ? "" : text) + "}";
    try (OutputStream os = conn.getOutputStream()) { os.write(body.getBytes("UTF-8")); }

    int code = conn.getResponseCode();
    InputStream is = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();
    String res = EA_readAll(is);
    conn.disconnect();

    // Respinse Format: [ [ {label,score}.. ] ] or [ {label,score}.. ]
    JSONArray outer = JSONArray.parse(res);
    JSONArray arr = (outer.size() > 0 && outer.get(0) instanceof JSONArray)
                    ? outer.getJSONArray(0) : outer;

    float vneg=0, neg=0, neu=0, pos=0, vpos=0;
    StringBuilder dist = new StringBuilder();

    for (int i = 0; i < arr.size(); i++) {
      JSONObject o = arr.getJSONObject(i);
      String label = o.getString("label").toLowerCase();
      float p = o.getFloat("score");

      if (label.contains("very negative")) vneg = p;
      else if (label.contains("negative"))  neg = p;
      else if (label.contains("neutral"))   neu = p;
      else if (label.contains("very positive")) vpos = p;
      else if (label.contains("positive"))  pos = p;
      else if (label.equals("label_0")) vneg = p;
      else if (label.equals("label_1")) neg  = p;
      else if (label.equals("label_2")) neu  = p;
      else if (label.equals("label_3")) pos  = p;
      else if (label.equals("label_4")) vpos = p;
      else if (label.contains("1")) vneg = max(vneg, p);
      else if (label.contains("2")) neg  = max(neg,  p);
      else if (label.contains("3")) neu  = max(neu,  p);
      else if (label.contains("4")) pos  = max(pos,  p);
      else if (label.contains("5")) vpos = max(vpos, p);
    }

    dist.append(String.format("VN:%.2f  N:%.2f  NEU:%.2f  P:%.2f  VP:%.2f", vneg, neg, neu, pos, vpos));
    out.distText = dist.toString();

    // Weighted → 0~1
    float weighted = vneg*0.00f + neg*0.25f + neu*0.50f + pos*0.75f + vpos*1.00f;
    float sum = vneg+neg+neu+pos+vpos;
    if (sum > 0.0001f) weighted /= sum;
    out.score01 = constrain(weighted, 0, 1);
    out.label = labelFromScore(out.score01);

    return out;
  } catch (Exception e) {
    e.printStackTrace();
    return out;
  }
}

String EA_readAll(InputStream is) throws IOException {
  BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"));
  StringBuilder sb = new StringBuilder();
  String line;
  while ((line = br.readLine()) != null) sb.append(line);
  br.close();
  return sb.toString();
}