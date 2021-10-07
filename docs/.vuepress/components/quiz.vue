<template>
  <div class="quiz">
      <div v-if="currentQuestion >= 0 && currentQuestion < questions.length">
        <h4 style="margin-bottom:16px;margin-left:-2px;">Question {{currentQuestion + 1}}:</h4>
        <question
        :value="getCurrentQuestion()"
        @input="selectedAnswer"
        ref="question"
        :key="getCurrentQuestion().id"
        />
      </div>
    <div class="action">
        <button class="btn btn-secondary action" @click="previousQuestion" v-if="currentQuestion > 0">
            Previous
        </button>
        <button class="btn btn-primary action" @click="nextQuestion" v-if="currentQuestion < questions.length - 1">
            Next
        </button>
        <button class="btn btn-primary action" @click="submit" v-if="currentQuestion == questions.length - 1">
            Submit
        </button>
    </div>
    
  </div>
</template>
<script>
import axios from "axios";
import question from "./question.vue";
export default {
  components: { question },
  name: "quiz",
  data: function(){
    return {
      questions: [],
      currentQuestion: -1
    };
  },
  created() {
    axios.get("http://localhost:1337/questions").then((res) => {
      this.$set(this, 'questions', res.data);
      this.nextQuestion();
    });
  },
  methods: {
    getCurrentQuestion() {
        return this.questions[this.currentQuestion];
    },
    nextQuestion() {
        if(this.currentQuestion < this.questions.length - 1) {
            this.currentQuestion++;
        }
    },
    previousQuestion() {
        if(this.currentQuestion > 0){
            this.currentQuestion--;
        }
    },
    submit() {

    },
    selectedAnswer(selected){
        this.questions[this.currentQuestion].selected = selected
        console.log(selected);
    }
  },
};
</script>
<style>
.quiz .action {
    text-align: center;
}
.quiz .action button {
  min-width: 240px;
  margin: auto;
}
</style>
