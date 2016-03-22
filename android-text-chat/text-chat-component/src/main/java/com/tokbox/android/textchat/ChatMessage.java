package com.tokbox.android.textchat;


import android.util.Log;

import java.util.UUID;

public class ChatMessage {

    private static final String LOG_TAG = "text-chat-message";

    private final String senderId; //required
    private final MessageStatus messageStatus; //required
    private final UUID messageId; //required
    private String senderAlias; //optional
    private String text; //optional
    private long timestamp; //optional

    public static enum MessageStatus {
        /**
         * The status for a sent message.
         */
        SENT_MESSAGE,
        /**
         * The status for a received message.
         */
        RECEIVED_MESSAGE
    }


    public ChatMessage(ChatMessageBuilder builder) {
        this.senderId = builder.senderId;
        this.messageId = builder.messageId;
        this.messageStatus = builder.messageStatus;
        this.text = builder.text;
        this.senderAlias = builder.senderAlias;
        this.timestamp = builder.timestamp;
    }

    public String getSenderId() {
        return senderId;
    }

    public UUID getMessageId() {
        return messageId;
    }

    public MessageStatus getMessageStatus() {
        return messageStatus;
    }

    public String getSenderAlias() {
        return senderAlias;
    }

    public String getText() {
        return text;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public void setSenderAlias(String senderAlias) {
        this.senderAlias = senderAlias;
    }

    public void setText(String text) {
        this.text = text;
    }

    public static class ChatMessageBuilder {

        private final String senderId;
        private final UUID messageId;
        private final MessageStatus messageStatus;
        private String senderAlias;
        private String text;
        private long timestamp;

        public ChatMessageBuilder(String senderId, UUID messageId, MessageStatus messageStatus) {
            this.senderId = senderId;
            this.messageId = messageId;
            this.messageStatus = messageStatus;
            this.timestamp = System.currentTimeMillis();
            this.senderAlias = "";
            this.text = "";
        }

        public ChatMessageBuilder senderAlias(String senderAlias) {
            this.senderAlias = senderAlias;
            return this;
        }

        public ChatMessageBuilder text(String text) {
            this.text = text;
            return this;
        }

        public ChatMessageBuilder timestamp(long timestamp) {
            this.timestamp = timestamp;
            return this;
        }

        public ChatMessage build() {
            ChatMessage message = new ChatMessage(this);

            boolean valid = validateChatMessageObject(message);

            if (!valid) {
                return null;
            }

            return message;
        }

        private boolean validateChatMessageObject(ChatMessage chatMessage) {
            Log.i(LOG_TAG, "status: " + chatMessage.getMessageStatus());
            if (senderId == null || senderId.isEmpty()) {
                Log.i(LOG_TAG, "SenderId cannot be null");
                return false;
            }
            if (messageId == null || messageId.toString().isEmpty()) {
                Log.i(LOG_TAG, "MessageId cannot be null");
                return false;
            }
            if (!chatMessage.getMessageStatus().equals(MessageStatus.RECEIVED_MESSAGE) && !chatMessage.getMessageStatus().equals(MessageStatus.SENT_MESSAGE)) {
                Log.i(LOG_TAG, "MessageStatus cannot be different to RECEIVED_MESSAGE ");
                return false;
            }

            return true;

        }
    }


}
