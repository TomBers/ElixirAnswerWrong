import {Socket, Presence} from "phoenix"

let presences = {};
let socket = new Socket("/socket", {params: {token: window.userToken}})

let current_user_id = 0;

let current_user = "";

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:messages", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp); setUserData(resp); setState(resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("presence_state", state => {
    presences = Presence.syncState(presences, state)
    renderOnlineUsers(presences)
})

channel.on("presence_diff", diff => {
    presences = Presence.syncDiff(presences, diff)
    renderOnlineUsers(presences)
})

channel.on("message:started", setQuestion);

channel.on("message:state_updated", setState);



function setState(resp) {
    const states = {initial: 0, enter_answer: 1, waiting: 2, quiz: 3};

    const state = current_user_id in resp ? resp[current_user_id].state : 0;

    switch(state) {
        case states.initial: document.querySelector("#playArea").innerHTML = renderInitalState(resp); addInitialEventListener(); break;
        case states.enter_answer: document.querySelector("#playArea").innerHTML = setQuestion(resp); addQuestionEvent(); break;
        case states.waiting: document.querySelector("#playArea").innerHTML = "<p>Waiting</p>"; break;
        case states.quiz: document.querySelector("#playArea").innerHTML = renderMultipleChoice(resp); setupQuizEvent(); break;
        default: document.querySelector("#playArea").innerHTML = "<p>Error</p>";
    }
}

function renderInitalState(resp) {
    const score = current_user_id in resp ? resp[current_user_id].score : 0
    return `<p>Score <strong>${score}</strong></p><button id="start">Next question</button>`;
}

function addInitialEventListener() {
    document.querySelector('#start').addEventListener('click', function() {
        channel.push('message:start')
    });
}


function setupQuizEvent() {
    document.querySelector('#quizAnswer').addEventListener('click', function() {
        document.getElementsByName('answer').forEach(function(radioButton) {
            if(radioButton.checked) {
                channel.push('message:guess', {current_user_id: current_user_id, guess: radioButton.id});
            }
        });

    });
}

function renderMultipleChoice(resp) {
   let answers = [`<h3>${resp["current_question"].question}</h3>`];
   shuffle(Object.keys(resp)).forEach(function(element) {
     answers.push(answerTemplate(resp[element]));
   });
   answers.push(`<br /><br /><button class="btn btn-primary" id="quizAnswer">Answer</button>`);
   return answers.join("")
}

function shuffle(array) {
  var currentIndex = array.length, temporaryValue, randomIndex;

  // While there remain elements to shuffle...
  while (0 !== currentIndex) {

    // Pick a remaining element...
    randomIndex = Math.floor(Math.random() * currentIndex);
    currentIndex -= 1;

    // And swap it with the current element.
    temporaryValue = array[currentIndex];
    array[currentIndex] = array[randomIndex];
    array[randomIndex] = temporaryValue;
  }

  return array;
}

function answerTemplate(answer) {
    return `      <label style="display: block;">
                    <input name="answer" id=${answer.id} type="radio" class="indigo accent-3" />
                    <span>${answer.answer}</span>
                  </label>`
}

function setQuestion(resp) {
    return `<h3>${resp["current_question"].question}</h3><div class="form-input"><input class="form-control" id="answer_text" name="answer" type="text"><button class="btn btn-primary" id="submitAnswer">Submit</button></div>`
}

function addQuestionEvent() {
    document.querySelector('#submitAnswer').addEventListener('click', function() {
        let ele = document.querySelector("#answer_text");
        if(ele.value !== "") {
            channel.push('message:answer', {current_user_id: current_user_id, answer: ele.value});
            ele.value = "";
        }
    });
}

function setUserData(resp) {
    current_user = resp.current_user_name;
    current_user_id = resp.current_user_id;
}

function renderOnlineUsers(presences) {
  let onlineUsers = Presence.list(presences, (_id, {metas: [user, ...rest]}) => {
    return onlineUserTemplate(user);
  }).join("")

  document.querySelector("#online-users").innerHTML = "<ol>" + onlineUsers + "</ol>";
}

function onlineUserTemplate(usr) {
      return `<li>${usr.username}</li>`
}

export default socket
