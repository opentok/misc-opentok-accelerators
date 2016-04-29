package com.tokbox.android.accpack.textchat;


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

    /**
     * Enumerations for sent and received message status.
     */
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

    /**
     * Constructor.
     * @param builder The ChatMessageBuilder to creates the instance.
     */
    public ChatMessage(ChatMessageBuilder builder) {
        this.senderId = builder.senderId;
        this.messageId = builder.messageId;
        this.messageStatus = builder.messageStatus;
        this.text = builder.text;
        this.senderAlias = builder.senderAlias;
        this.timestamp = builder.timestamp;
    }

    /**
     * Get the sender ID.
     * @return The sender ID.
     */
    public String getSenderId() {
        return senderId;
    }

    /**
     * Get the message ID.
     * @return The message ID.
     */
    public UUID getMessageId() {
        return messageId;
    }

    /**
     * Get the message status.
     * @return The message status.
     */
    public MessageStatus getMessageStatus() {
        return messageStatus;
    }

    /**
     * Get the sender alias.
     * @return The sender alias.
     */
    public String getSenderAlias() {
        return senderAlias;
    }

    /**
     * Get the message text.
     * @return The message text.
     */
    public String getText() {
        return text;
    }

    /**
     * Get the message timestamp.
     * @return The message timestamp.
     */
    public long getTimestamp() {
        return timestamp;
    }

    /**
     * Set the message timestamp.
     * @param timestamp The message timestamp.
     */
    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    /**
     * Set the sender alias.
     * @param senderAlias The sender alias.
     */
    public void setSenderAlias(String senderAlias) {
        this.senderAlias = senderAlias;
    }

    /**
     * Set the message text.
     * @param text The message text.
     */
    public void setText(String text) {
        this.text = text;
    }

    /**
     * ChatMessageBuilder static class used in the ChatMessage constructor to instantiate a ChatMessage.
     */
    public static class ChatMessageBuilder {

        private final String senderId;
        private final UUID messageId;
        private final MessageStatus messageStatus;
        private String senderAlias;
        private String text;
        private long timestamp;

        /**
         * Constructor.
         * @param senderId The sender ID.
         * @param messageId The message ID.
         * @param messageStatus The message status.
         */
        public ChatMessageBuilder(String senderId, UUID messageId, MessageStatus messageStatus) {
            this.senderId = senderId;
            this.messageId = messageId;
            this.messageStatus = messageStatus;
            this.timestamp = System.currentTimeMillis();
            this.senderAlias = "";
            this.text = "";
        }

        /**
         * Set a sender alias on the ChatMessage that has to be build by this ChatMessageBuilder
         * @param senderAlias The sender alias.
         */
        public ChatMessageBuilder senderAlias(String senderAlias) {
            this.senderAlias = senderAlias;
            return this;
        }

        /**
         * Set a text message string on the ChatMessage that has to be build by this ChatMessageBuilder
         * @param text The message text.
         */
        public ChatMessageBuilder text(String text) {
            this.text = text;
            return this;
        }

        /**
         * Set a timestamp on the ChatMessage that has to be build by this ChatMessageBuilder
         * @param timestamp The message timestamp.
         */
        public ChatMessageBuilder timestamp(long timestamp) {
            this.timestamp = timestamp;
            return this;
        }

        /**
         * Creates a new ChatMessage.
         */
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
