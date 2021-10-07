<template>
  <div class="question">
    <div class="title">
      <markdown-it-vue class="md-question" :content="val.questionTitle" />
    </div>
    <div class="options">
        <div v-if="val.questionType == constants.QUESTION_TYPE.SingleChoice">
            <div class="option" v-for="(option, index) in val.options" :key="index">
                <div class="radio">
                <label>
                    <input
                    type="radio"
                    :name="val.id"
                    :value="index"
                    v-model="val.selected"
                    />
                    <markdown-it-vue class="md-option" :content="option.content" />
                </label>
                </div>
            </div>
        </div>
        <div v-else-if="val.questionType == constants.QUESTION_TYPE.MultipleChoice">
            <div class="option" v-for="(option, index) in val.options" :key="index">
                <div class="checkbox">
                <label>
                    <input
                    type="checkbox"
                    :name="val.id"
                    :value="index"
                    v-model="val.selected"
                    />
                    <markdown-it-vue class="md-option" :content="option.content" />
                </label>
                </div>
            </div>
        </div>
        <div v-else-if="val.questionType == constants.QUESTION_TYPE.TrueFalse">
            <div class="option">
                <div class="radio">
                <label>
                    <input
                    type="radio"
                    :name="val.id"
                    value="1"
                    v-model="val.selected"
                    />
                    True
                </label>
            </div>
            <div class="option">
                <label>
                    <input
                    type="radio"
                    :name="val.id"
                    value="0"
                    v-model="val.selected"
                    />
                    False
                </label>
                </div>
            </div>
        </div>
    </div>
  </div>
</template>
<script>
import MarkdownItVue from "markdown-it-vue";
import constants from './constant';
export default {
  name: "question",
  props: {
    value: Object
  },
  created(){
      console.log(this.value);
  },
  components: {
    MarkdownItVue,
  },
  data: function(){
    this.value.selected = this.value.selected === undefined?(this.value.questionType == constants.QUESTION_TYPE.MultipleChoice ? [] : null):this.value.selected;
    return {
      val: this.value,
      constants: constants
    };
  }
};
</script>
<style>
.question .md-option {
  float: right;
  margin-left: 8px;
}
.question .options {
    margin-top: 24px;
}
</style>
